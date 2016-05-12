# -*- coding: utf-8 -*-
'''
Created on 07.01.2013

@author: azl
'''
from django.conf.urls.defaults import patterns, include, url
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User
from django.views.generic.edit import FormView
from django.views.generic import TemplateView
from django.forms.util import ErrorList
from django.core.urlresolvers import reverse
from django.core.mail import  EmailMessage
from django.contrib.auth import authenticate, login
from django.http import HttpResponseRedirect,HttpResponse, Http404
from bson import json_util
from bson import ObjectId
from django import forms
from powerdns import models as pmodels
import dns.resolver
import json, gridfs, base64, hashlib, datetime, re, pymongo
from django.core.context_processors import csrf
from django.shortcuts import render_to_response
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from utils import _get_current_site, check_roles,sites,accounts,get_application_obj

from django.contrib import admin
admin.autodiscover()

try:
    from bs4 import BeautifulSoup as bs
except ImportError as e:
    from BeautifulSoup import BeautifulSOAP as bs

# from general_service import UrlPatterns

#P = UrlPatterns(namespace = "os")


#P.add(r'^$', views.ConstructorPage.as_view(), name="constructor",label="Конструктор страниц")
#P.add(r'^a/((?P<year>\d{4}))$', views.ConstructorPage.as_view(), name="constructor",label="Конструктор страниц")

MAX_NON_BLOB = 15000

def profile_page(req, *k, **kw):
    if req.user.is_authenticated():
        user_id = req.user.id

        rec = req.storage.find(accounts, {'django_user_id':user_id})
        invites = req.storage.find('invite', {'email': req.user.email})
        c = {}
        if rec:
            c.update({'sites': rec })
        else:
            c.update({'sites': False})
        c.update({} if not invites else {'invites': list(invites)})

        c['user_app_key'] = hashlib.md5(req.user.password).hexdigest()

        c.update(csrf(req))
        return render_to_response("my_hosts.html", c)
    else:
        c = {}
        c.update(csrf(req))
        return  HttpResponseRedirect('/_/auth/login/') # render_to_response("main_page.html", c)


def data_updaters(req, type_, cursor):
    dt,app = type_.split('@')
    for item in cursor:
        if dt == sites:
            for p in item['pages']:
                if 'show_in_menu' not in item['pages'][p]:
                    item['pages'][p]['show_in_menu'] = True
                if item['pages'][p].get('blocks', False):
                    del (item['pages'][p])['blocks']
            if not item['Roles']:
                s = _get_current_site(req)
                if s['django_user_id'] == req.user.id:
                    item['Roles'] = [{'user': req.user.username, 'roles':['admin#generic.' + settings.MY_MAIN_SITE ] } ]

        yield item


    # return cursor


    
def get_application(req, app_name):
    app = get_application_obj(req, app_name)
    resp = HttpResponse(json.dumps(app, default = json_util.default))
    return resp

def put_application_to_global_index(req, site, app):
    new_values = dict([(k,v) for k,v in app.items() if k in ['date_changed'] ] )
    app_ix = {'full_name': app['app_name'], 'title': app['title'], 'site_id': site['_id'] }

    app = req.storage.findOne('global_app_index', app_ix)
    if app is not None:
        app.update(new_values)
        req.storage.safe_update( 'global_app_index', app )
    else:
        req.storage.insert('global_app_index', app_ix )

def find_application(req):
    if 'iname'  in req.GET.keys():
        iname = req.GET.get('iname', '')

        #search app over global collection
        apps = list(req.storage.find('global_app_index', {'title': re.compile(iname, flags = re.IGNORECASE) }))
    else:
        site = _get_current_site( req )
        apps = list(req.storage.find('application', {"site_id": site['_id'] }))

    return HttpResponse(json.dumps( {"apps": apps }, default = json_util.default  ))

def adding_application(req):

    def save_app(site, app, to_global = False):
        appl = req.storage.findOne('application', {'app_name': app['app_name'], "site_id": site['_id']})
        if appl:
            appl.update(app)
            # print "DC", appl.get('date_changed')
            res = req.storage.safe_update('application', appl)
            id_ = res[1]['_id']
        else:
            id_ = req.storage.insert('application', app)
        if to_global:
            put_application_to_global_index( req, site, app )

        return id_

    app = json.loads(req.POST.get('x-data'))
    site = _get_current_site(req)
    if "app_name" not in app:
        app['app_name'] = ".".join([app.get('name',''), site['hostname'][0] ])

    app_def_name = app['app_name']
    app_name_with_host = app_def_name + u'.' + site['hostname'][0]
    app['app_name'] = app_name_with_host
    app['date_changed'] = datetime.datetime.now()

    if req.user.is_authenticated():
        app['site_id']  = site['_id']
        obj_id = save_app(site, app)
    else:
        auth_token = req.POST.get('crypt', "")

        username = req.POST.get('username', '')
        make_it_global = req.POST.get('make_it_global', False)

        user = User.objects.get( username = username )
        my_cr = hashlib.md5(":".join([user.username, hashlib.md5(user.password).hexdigest() ])).hexdigest()

        if my_cr == auth_token: # authentication
            app['site_id'] = site['_id']
            obj_id = save_app(site, app, to_global = make_it_global )
        else:
            raise ValueError("Not authenticated")

    return HttpResponse(json.dumps({'success':True, "id": obj_id }, default = json_util.default ))

def blob_storage(req, obj, site_id):
    if isinstance(obj, dict):
        return dict([(k, blob_storage(req, v, site_id )) for (k,v) in obj.iteritems() ] )
    elif isinstance(obj, list):
        return [blob_storage(req, v, site_id ) for v in obj ]

    elif isinstance(obj, (str,unicode)):
        if len(obj) > MAX_NON_BLOB:
            # print obj
            obj_type = obj.split(',')[0]
            if(obj_type[:4] == 'data'):
                a =  obj_type.split(':')[1]
                if ';' in a:
                    mime_type, encoding = a.split(';')
                else:
                    mime_type = a
                    encoding = None
                if encoding == 'base64':
                    obj_d = obj.split(',')[1]
                    res = base64.decodestring(obj_d)
                else:
                    raise ValueError('unknown encoding')
            else:
                "This is just a long string"
                res = obj.encode('utf-8')
                mime_type = 'text/plain'
            gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
            fh = gf.new_file()
            # print "CONTENT_TYPe", mime_type
            fh.content_type = mime_type
            fh.write(res)
            fh.close()
            blob_obj =  {"blob":1, "file_id":fh._id, 'site_id': site_id}
            req.storage.save('blob_object',  blob_obj)
            return blob_obj
        else:
            return obj
    else:
        return obj


def setTriggers(req, site ,datatype, event_type, object):
    hostname =  req.META['HTTP_HOST']
    # print "TRIGGET",  unicode(datatype) == unicode(sites + u'@generic.' + settings.MY_MAIN_SITE)
    if datatype == unicode(sites + '@generic.' + settings.MY_MAIN_SITE):


        metas = object.get('seo',{}).get('metas',{})
        site['metas'] = "\n".join(metas.values())

        textColors = object.get('textColors',{})
        print textColors
        ass = {"link_color":"#id-top-cont A:link",
               "text_color":"#id-top-cont",
               "hover_color":"#id-top-cont A:hover",
               "active_color":"#id-top-cont A:active",
               "visited_color":"#id-top-cont A:visited"}
              
        colors = "\n".join(["%s{color:%s}\n"%(ass[k], textColors[k]['rgb']) for k in textColors if textColors[k].get('rgb', False)])
        # print "colors", ass, colors, textColors

        site['textColors'] = colors

        domains = object.get('domains', [])
        doms = [ site['hostname'][0] ]
        for d in domains:
            if d not in doms:
                doms.append(d)
        if 'favicon' in object:
            site['favicon'] = object['favicon']

        site['hostname'] = doms
        object['domains'] = doms

        urls = []
        for page, value in object['pages'].items():
            if value['show_in_menu']:
                urls.append( "<a href='#!%s'>%s</a>" % (page, value['title']) )

        site['cached_urls'] = "\n".join(urls)

        # Необходимо доставать этот объект целиком перед сохранением, поскольку для оптимизации мы его
        # Достаем без кеша - только учетные данные
        full_object = req.storage.findOne(accounts, {'_id': site['_id'] })
        full_object.update(site) # Вставляем новые данные
        req.storage.safe_update(accounts, full_object)



def data_deleter(req):
    site = _get_current_site(req)
    if site is None:
        return HttpResponse ("{}")
    else:
        type = req.POST.get('type')
        if ('@' in type):
            mongo_db, app = type.split('@')
        else:
            mongo_db = type

        opts   = json.loads(req.POST.get('o','{}'), object_hook = json_util.object_hook)
        q = opts['q']
        q['site_id'] = site['_id']

        if check_roles(req, type, 'del', site=site):
            req.storage.remove(mongo_db, q)
            s = req.storage.find(mongo_db, q)
            # raise IndexError('dds')
            return HttpResponse(json.dumps({"success": True} , default = json_util.default) )
        else:
            raise ValueError("no permission")



def data_connector(req):
    site = _get_current_site(req)
    if site is None:
        return HttpResponse ("{}")
    else:
        if req.META['REQUEST_METHOD'] == 'POST':
            obj =  json.loads( req.POST.get('x-data'),object_hook = json_util.object_hook  )
            if 'is_unique' in req.POST.keys():
                is_unique = req.POST.get('is_unique')
            else: is_unique = False
            to_store = blob_storage(req, obj['object'] , site['_id'] )
            to_store['site_id'] = site['_id']
            type = obj['type']
            if ('@' in type):
                mongo_db, app = type.split('@')
            else:
                mongo_db = type
            if check_roles(req, type, 'add', site = site):
                if is_unique:
                    res = req.storage.find(mongo_db, to_store)
                    if res.count() > 0:
                        return HttpResponse(json.dumps({"success": False, "_id": res[0]['_id']} , default = json_util.default) )
                setTriggers(req, site, type, 'save', to_store)
                if "_id" in to_store:
                    req.storage.safe_update(mongo_db, to_store)
                else:
                    req.storage.insert(mongo_db, to_store)
                return HttpResponse(json.dumps({"success": True, "_id": to_store['_id']} , default = json_util.default) )
            else:
                raise ValueError('no permission to save')
        else:
            type = req.GET.get('type')
            r    = json.loads(req.GET.get('o','{}'), object_hook = json_util.object_hook )
            #print r
            q = {'site_id': site['_id']}
            if ('@' in type):
                mongo_db, app = type.split('@')
            else:
                mongo_db = type

            if check_roles(req, type, 'view', site = site):
                if 'q' in r:
                    q.update( r['q'] )
                    #print q
                    objs = req.storage.find(mongo_db, q)
                else:
                    objs = req.storage.find(mongo_db, q)
                
                if 'o' in r:
                    ordering = r['o']
                    ordering = [ tuple(i) for i in ordering]
                    objs.sort(ordering)
                
                    
                total_amount = objs.count()
                if 'p' in r:
                    cur_page = r['p'].get('current_page', 0)
                    per_page = r['p'].get('per_page', 20)
                else:
                    cur_page = 0
                    per_page = 100
                total_pages = total_amount / per_page + (1 if total_amount % per_page else 0)
                beg  = cur_page * per_page
                fin  = beg + per_page
                lst = list( objs[ beg:fin ] )

                lst = list(data_updaters(req, type, lst))

                send = {'total_pages': total_pages,
                        'total_amount':total_amount,
                        'objects' : lst }
                return HttpResponse(json.dumps(send, default = json_util.default))
            else:
                raise ValueError('no permission to retrieve object')

def blob_extruder(req, blob_id):

    gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
    f = gf.get( ObjectId(blob_id )) # Здесь надо узнать - есть ли файл, если нету - поискать в базе его путь
    mt =  f.content_type
    #raise IndexError(str(req))
    is_etag = req.META.get('HTTP_IF_NONE_MATCH', '') == f.md5
    is_last = req.META.get('HTTP_IF_MODIFIED_SINCE', '') == f.upload_date.strftime('%a %b %d %Y %H:%M:%S GMT')
    if not any([is_etag , is_last]):
        is_invalid_mt = mt is None or mt == ''
        resp = HttpResponse( f , mimetype=mt if not is_invalid_mt else "Application/octet-stream")
        resp['ETag'] = f.md5
        resp['Last-Modified'] = f.upload_date.strftime('%a %b %d %Y %H:%M:%S GMT') #"Tue, 16 Jul 2013 23:54:26 GMT")
        #raise IndexError("WE DO INSTALL TAG")
        return resp

    else:
        r = HttpResponse()
        r.status_code = 304
        return r
        
def  blob_remover(req, blob_id):
    gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
    o = req.storage.findOne('blob_object', ObjectId(blob_id) )
    if o is not None:
        site_id = o.get('site_id')
        site = _get_current_site(req)
        if site_id == site['_id']:
            print "new style"
            file_id = o.get('file_id')
            gf.delete(file_id)
            req.storage.remove("blob_object", {"_id": file_id })
            return HttpResponse( "ok" )
    else:
        print "old style"
        gf.delete(ObjectId(blob_id)) 
        return HttpResponse( "ok old" )
        
class RegisterMixture(forms.Form):
    def __init__(self, *k, **kw):
        if not hasattr(self, 'request'):
            if 'request' in kw:
                self.request = kw['request']
                del kw['request']
                super (RegisterMixture, self).__init__(*k, **kw)
            else:
                raise ValueError("No request provided")

    def clean(self):

        if 'password1' in self.cleaned_data and 'password2' in self.cleaned_data:
            if self.cleaned_data['password1'] != self.cleaned_data['password2']:
                raise forms.ValidationError(_("The two password fields didn't match."))

        if 'email' in self.cleaned_data:

            c = User.objects.filter(username = self.cleaned_data['email']).count()
            if c > 0 :
                if 'email' in self._errors:
                    self._errors['email'].append("Email is already registered ")
                else:
                    self._errors['email'] = ErrorList(["Email is already registered "])

                raise forms.ValidationError(_("Checkout form"))

        if 'hostname' in self.cleaned_data:
            full  = self.cleaned_data['hostname'].lower() + '.' + settings.MY_BASE_HOST
            c = self.request.storage.findOne(accounts, {"hostname": full } )

            if c  :
                if 'hostname' in self._errors:
                    self._errors['hostname'].append("Hostname busy")
                else:
                    self._errors['hostname'] = ErrorList(["Hostname busy"])

                raise forms.ValidationError(_("Checkout form"))


        return self.cleaned_data

class RegisterForm(RegisterMixture):
    hostname    = forms.RegexField(regex = r'^[\w-]+$', max_length = 30, label = _('Hostname'), error_messages={'invalid': _("Hostname cannot contain restricted symbols")}  )
    email       = forms.EmailField()
    password1 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password"))
    password2 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password (again)"))
class NoSiteRegisterForm(RegisterMixture):
    email       = forms.EmailField()
    password1 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password"))
    password2 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password (again)"))


class RegistrationView( FormView ):
    template_name = 'registration/registration_form.html'
    success_url = None
    form_class = RegisterForm
    no_site = False
    #def get_form_class(self):
    #    return RegisterForm;


    def get_form_class(self):
        if self.no_site:
            return NoSiteRegisterForm
        else:
            return RegisterForm

    def get_form_kwargs(self):
        kw = super(RegistrationView, self).get_form_kwargs()
        kw.update({'request':self.request })
        return kw

    def get(self, req, *k, **kw):
        self.request = req
        return super(RegistrationView, self).get(req,*k,**kw)
    def post(self, req, *k, **kw):
        self.request = req
        return super(RegistrationView, self).post(req,*k,**kw)

    def form_valid(self, form):
        cleaned_data = form.cleaned_data

        hostname, email, password = cleaned_data.get('hostname',''), cleaned_data['email'], cleaned_data['password1']

        hash_ = hashlib.md5(hostname + email + password + repr(datetime.datetime.now())).hexdigest()[:30]

        new_user = User.objects.create(username=email, email=email, last_name = hash_,  is_active = False , is_staff = False )

        new_user.set_password(password)
        new_user.save()

        new_user = authenticate(username=email,
                                password=password )
        login(self.request, new_user)

        if not self.no_site:
            full = hostname.lower() +  '.' + settings.MY_BASE_HOST
            site = {"hostname":[ full ],
                    "email" : email,
                    "django_user_id" : new_user.id }

            s = self.request.storage.insert(accounts, site )


            d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)

            r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d, ttl=60*60*24)


        if settings.DEBUG:
            sender = 'vg.stavenko@yandex.ru'
        else:
            sender = 'info@be-web.ru'

        subj = 'Be-web registration confirmation'
        body = 'Please, click on the <a href="http://be-web.ru/_/activate/%s/">link</a> to activate account' % hash_
        recv  = [ email ]

        email = EmailMessage(subj, body, sender, recv )
        email.content_subtype = "html"
        email.send()


        return HttpResponseRedirect(reverse("registration_complete"))
    def form_invalid(self, form):
        return self.render_to_response(self.get_context_data(form=form))


class ActivationView( TemplateView ):
    template_name = 'registration/activate.html'

    def get(self,req, *k, **kw):
        key = kw.get('activation_key')
        u =  User.objects.get(last_name = key)
        u.last_name = ''
        u.is_active = True
        u.save()

        return super(ActivationView, self).get(req, *k, **kw)

def restore_password(req):
    if req.POST.get('key', False):
        key = req.POST.get('key', '')
        u = User.objects.get(last_name = key)
        pw1 = req.POST.get('password1','')
        pw2 = req.POST.get('password2','!')
        print pw1, pw2
        if pw1 == pw2:
            print "!!!"
            u.set_password(pw1)
            u.save()

            return HttpResponseRedirect("/_/auth/login/")

        if False:
            return HttpResponseRedirect("/_/auth/login/")
    else:
        c = {'key': req.GET.get('key')}
        c.update(csrf(req))

        return render_to_response("registration/restore_password.html", c)



def forgot_password(req):
    if req.POST:
        email = req.POST.get('username')
        key = hashlib.sha256(str(datetime.datetime.now()) + email) .hexdigest() [:30]
        u = User.objects.get(username = email)
        u.last_name = key
        u.save()
        subj = "Запрос на восстановление пароля"
        body = """
        Восстановление пароля конструктора сайтов be-web.ru. Для продолжения процедуры восстановления нажмите на ссылку ниже
        <a href='http://be-web.ru/_/auth/restore_password/?key=%s'>Восстановить пароль</a> """ % key
        if settings.DEBUG:
            sender = 'vg.stavenko@yandex.ru'
        else:
            sender = 'info@be-web.ru'
        email = EmailMessage(subj, body, sender, [email] )
        email.content_subtype = "html"
        try:
            email.send()
        except Exception as e:
            print e
        return render_to_response("registration/forgot_password_sent.html")
    else:
        c = {}
        c.update(csrf(req))

        return render_to_response("registration/forgot_password.html", c)









class NewHostView(TemplateView):
    def post(self, req, *k, **kw):
        if 'hostname' in req.POST:
            new_hostname = req.POST['hostname']
            full = new_hostname +  '.' + settings.MY_BASE_HOST
            sites = req.storage.find(accounts, {'django_user_id': req.user.id} )

            is_busy = req.storage.findOne(accounts, {"hostname": full})

            if is_busy is None:

                if sites.count() > 0 and sites.count() < 5 :
                    site = {"hostname":[ full ],
                            "email" : req.user.username,
                            "django_user_id" : req.user.id }
                    # raise ValueError('a')
                    s = req.storage.insert(accounts, site )
                    d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
                    r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)

                elif sites.count() == 0:
                    site = {"hostname":[ full ],
                            "email" : req.user.username,
                            "django_user_id" : req.user.id }

                    s = req.storage.insert(accounts, site )
                    d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
                    r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)
        return HttpResponseRedirect('/_/profile/')


def send_email(req):
    site = _get_current_site(req)
    now = datetime.datetime.now()

    er = req.session.setdefault('email_succeeded', {}).get(site['_id'],[])

    if er is None:
        er = []

    amount = [e for e in er if (now - e).seconds < 10]
    if len(amount) > 10:
        return HttpResponse (json.dumps({'succes':False, 'reason':"To many letters from this site, try again later"}))
            #raise ValueError('more than 1 letter per second per site - is too often')
    else:
        subj = req.POST.get('subject','')
        body = req.POST.get('body','')
        if settings.DEBUG:
            sender = 'vg.stavenko@yandex.ru'
        else:
            sender = 'info@be-web.ru'
        recv = req.POST.get('to')
        m = e_re.match(recv)
        # print m,recv
        if not m:
            recv = _get_role_email(req, site, recv)


        email = EmailMessage(subj, body, sender, [recv] )
        email.content_subtype = "html"
        try:
            email.send()
        except Exception as e:
            print e

        amount.append( datetime.datetime.now() )
        req.session['email_succeeded'][site['_id']] = amount
        return HttpResponse(json.dumps({'succes':True }))


DS = """		<style>

		canvas {
			    image-rendering: optimizeSpeed;             // Older versions of FF
			    image-rendering: -moz-crisp-edges;          // FF 6.0+
			    image-rendering: -webkit-optimize-contrast; // Webkit
			                                                //  (Safari now, Chrome soon)
			    image-rendering: -o-crisp-edges;            // OS X & Windows Opera (12.02+)
			    image-rendering: optimize-contrast;         // Possible future browsers.
			    -ms-interpolation-mode: nearest-neighbor;   // IE
			}
			.drop-hover{
				background-color: blue;
			}
			.clear {
				background: none;
				border: 0;
				clear: both;
				display: block;
				float: none;
				font-size: 0;
				list-style: none;
				margin: 0;
				padding: 0;
				overflow: hidden;
				visibility: hidden;
				width: 0;
				height: 0;
			}
			html,body{
				margin:0;
				overflow:auto;
				height:100%;

			}

		</style>"""

def site_cacher(req):
    sdata = req.POST.get('page_cache','')
    sjs = json.loads(sdata)
    old_dt = None
    cur_acc = _get_current_site(req)
    cache = {}
    for i in sjs:
        head = sjs[i]['head']
        cont = sjs[i]['cont']
        body = "<body>%s</body>"% cont
        S = bs(body)
        html = u"<html> <head>%s %s</head> %s</html>" %( head, DS, body)
        key = i[2:]
        cache[key] = {"html":html, 'head':head, 'cont':cont}


    cur_acc['cache'] = cache
    full_object = req.storage.findOne(accounts, {'_id': cur_acc['_id'] } )
    full_object.update(cur_acc) # Вставляем новые данные

    req.storage.safe_update(accounts, full_object)
    return HttpResponse("")
def check_domain(req):
    domain = req.GET.get('domain','')
    key = req.GET.get('key','')
    try:

        answers = dns.resolver.query('bewebconfirm.' + domain, 'TXT')
        answer = answers[0].strings[0]
        if answer == key:
            print answer, key
            return HttpResponse(json.dumps({'domain_confirm': True }))
        else:
            # print answer, key
            return HttpResponse(json.s({'domain_confirm': False }))

    except Exception as e:
        #print e
        return HttpResponse(json.dumps({'domain_confirm': False }))



urlpatterns = patterns("",



    url(r'^blob/(?P<blob_id>[a-zA-Z0-9].*)/', blob_extruder),
    url(r'^del_blob/(?P<blob_id>[a-zA-Z0-9].*)/', blob_remover),


    url(r'^a/(?P<app_name>.*)/', get_application),
    url(r'^app/add/', adding_application),
    url(r'^app/list/', find_application),

    url(r'^data/$', data_connector),
    url(r'^data/delete/$', data_deleter),

    url(r'^site_cache/$', site_cacher),


    url(r'^email/', send_email, name = "send_email"),
    url(r'^check_domain/', check_domain, name = "check_domain"),
    url(r'^profile/', profile_page , name = "profile_page"),


    url(r'^register/$', RegistrationView.as_view(), name='registration_register'),
    url(r'^register/no_site/$', RegistrationView.as_view( no_site = True ), name='registration_register', ),

    url(r'^activate/(?P<activation_key>\w+)/$',ActivationView.as_view(), name='registration_activate'),

    url(r'^register/new_host/', NewHostView.as_view(), name = 'registration_addhost' ),

    url(r'^register/complete/', TemplateView.as_view(template_name='registration/registration_complete.html'), name='registration_complete' ),
    url(r'^activate/complete/$',TemplateView.as_view(template_name='registration/activation_complete.html'),name='registration_activation_complete'),

    url(r'^auth/login/', 'django.contrib.auth.views.login', {'template_name':'registration/auth.html'} , name='login'),
    url(r'^auth/logout/', 'django.contrib.auth.views.logout', {'template_name':'registration/logout.html'}, name ='logout' ),

    url(r'^auth/forgot_passwd/', forgot_password, name='forgot_password'),
    url(r'^auth/restore_password/', restore_password, name='restore_password'), )
