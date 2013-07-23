# -*- coding:utf-8 -*-
from django.conf.urls.defaults import patterns, include, url

from django.http import HttpResponseRedirect,HttpResponse, Http404
from django.template import RequestContext
from django.shortcuts import render_to_response
from django.core.context_processors import csrf
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth.models import User
from django.views.generic.edit import FormView
from django.views.generic import TemplateView
from django.core.mail import send_mail
from django.forms.util import ErrorList
from django.core.urlresolvers import reverse

from django.contrib.auth import authenticate, login
from django.conf import settings
import json, gridfs, base64, hashlib, datetime
from bson import json_util
from bson import ObjectId
from django import forms
from powerdns import models as pmodels
import bson

    



Site_json = """{"_Apps":["generic","theshop"],"layout":{"cols":12,"fixed":true,"padding":{"hor":10,"ver":3},"width":960,"drawen_lines":30,"base_height":50},"colors":{"type":"mono","base":120,"brightness":100,"lights":50,"saturation":100,"shadows":50},"backgrounds":{},"pages":{"":{"layout":"same","title":"Main page of my project","blocks":{"0:0":{"width":3,"height":3,"widget":{"name":"generic.text","data":"Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."}},"8:0":{"width":4,"height":2,"widget":{"name":"generic.text","data":"Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."}},"3:0":{"width":5,"height":5,"widget":{"name":"generic.image","data":{}}}}},"about":{"layout":"same","title":"Page about project","blocks":{"0:0":{"width":12,"height":3,"widget":{"name":"generic.text","data":"Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."}},"0:3":{"width":12,"height":2,"widget":{"name":"generic.text","data":"Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."}},"0:5":{"width":5,"height":5,"widget":{"name":"generic.text","data":"Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat."}}}}},"Applications":{"generic":{"types":{"image":{"tip":"text","name":"text","binary":"binary","id":"id"},"text":{"id":"id","content":"html"}},"title":"Basic Site","widgets":{"text":{"title":"Текстовое поле"},"image":{"title":"Картинка"}}},"theshop":{"title":"The shop","_common_per_page":5,"_product_list_current_page":0,"widgets":{}}}} """ 
Site = json.loads(Site_json)
"""
     if req.POST:
        
        port = int(req.META['SERVER_PORT'])
        host = settings.MY_BASE_HOST
        site_name = req.POST.get('site_name')
        owner_email = req.POST.get('email')
        
        v_host = [site_name , '.' , host ]
        if port != 80:
            v_host.append(":")
            v_host.append(str(port))
        
        site = {"hostname":["".join(v_host) ],
                "email" : owner_email }
        s = req.storage.insert("general_sites", site )
        #raise IndexError("STOP")
        return HttpResponseRedirect("http://" + site["hostname"][0]+ "/")
        
    else:
"""    

accounts = "accounts"
sites    = 'sites'
redirect = HttpResponseRedirect  
def _my_base(req, *k, **kw):

    #print req.user
    if req.user.is_authenticated():
        user_id = req.user.id
        
        rec = req.storage.findOne(accounts, {'django_user_id':user_id})
        # print user_id, rec
        if rec:
            c = {'sites':rec['hostname']}
        else:
            c = {'sites': False}
        c.update(csrf(req))
        return render_to_response("my_hosts.html", c)
        
    else:
        
        c = {}
        c.update(csrf(req))
    
        return  HttpResponseRedirect('/register/') # render_to_response("main_page.html", c)


def site_view(site, req, *k, **kw):

    
    site['id'] = site['_id']
    c = RequestContext(req)
    c['site'] = site
   

    return render_to_response("constructor/displayer_page.html", c)
    
def site_edit(site, req, *k, **kw):
    c = RequestContext(req)
    is_debug = settings.DEBUG
    # raise ValueError("%s, %s" % (req.user.id, site['django_user_id']))
    if req.user.id == site['django_user_id'] or is_debug:
        site['id'] = site['_id']
        c['site'] = site
   
        return render_to_response("constructor/constructor_page.html", c)
    else:
        return HttpResponseRedirect('/')


def _get_current_site(req):
    host = req.META['HTTP_HOST']
    if ':' in host:
        bh, port = host.split(':')
    else:
        bh = host
        port = ''
    
    if bh == settings.MY_BASE_HOST:
        return None
    else:
        #print host
        site = req.storage.findOne(accounts, {"hostname": bh})
        return site
    

def base(req, *k, **kw):
    
    host = req.META['HTTP_HOST']
    #if ':' in host:
    #    bh, port = host.split(':')
    #else:
    #    bh = host
    #    port = ''
    
    if host == settings.MY_BASE_HOST:
        return _my_base(req,*k,**kw)
    else:
        #print host
        site = req.storage.findOne(accounts, {"hostname": host})
        # raise IndexError("S")
        if site:
            if kw.get('is_admin', False):
                return site_edit(site,req,*k,**kw)
            else:
                return site_view(site,req, *k, **kw)
        else:
            if port:
                return HttpResponseRedirect("http://" + settings.MY_BASE_HOST + ":" + port + "/")
            else:
                return HttpResponseRedirect("http://" + settings.MY_BASE_HOST  + "/")
                

def get_app(req, app_name = None):
    return HttpResponse("{init:function(to){ this.to= to},draw: function(){ $('<div>').text('this is an example app').appendTo( this.to) }}", mimetype="text/plain")

def get_app_data(req,app_name):
     return HttpResponse("{}", mimetype="text/plain")
 
MAX_NON_BLOB = 65536

def data_updaters(type_, cursor):
        
    for item in cursor:
        if type_ == sites:
            for p in item['pages']:
                if 'show_in_menu' not in item['pages'][p]:
                    item['pages'][p]['show_in_menu'] = True
                    
                if type(item['pages'][p].get('blocks', None)) == dict:
                    
                    new_blocks = []
                    for pos, bl in item['pages'][p]['blocks'].iteritems():
                        x, y =pos.split(':')
                        bl['x'] = x
                        bl['y'] = y
                        
                        new_blocks.append(bl)
                    item['pages'][p]['blocks'] = new_blocks
        # print item
        yield item
                
                    
    # return cursor 
def data_deleter(req):
    site = _get_current_site(req)
    if site is None:
        return HttpResponse ("{}")
    else:
        type = req.POST.get('type')
        opts   = json.loads(req.POST.get('o','{}'),object_hook = json_util.object_hook)
        q = opts['q']
        q['site_id'] = site['_id']
        
        req.storage.remove(type, q)
        s = req.storage.find(type, q)
        raise IndexError('dds')
        return HttpResponse(json.dumps({"success": True} , default = json_util.default) )
        
def data_connector(req):
    site = _get_current_site(req)
    if site is None:
        return HttpResponse ("{}")
    else:
            
        if req.META['REQUEST_METHOD'] == 'POST':
            # data = req.POST.get('object')
            #type = req.POST.get('type')
            obj =  json.loads( req.POST.get('x-data'),object_hook = json_util.object_hook  )
        
        
        
            def blob_storage(obj):
                if isinstance(obj, dict):
                    return dict([(k, blob_storage(v)) for (k,v) in obj.iteritems() ] )
                elif isinstance(obj, list):
                    return [blob_storage(v) for v in obj ] 
                elif isinstance(obj, (str,unicode)):
                    if len(obj) > MAX_NON_BLOB:
                        obj_type = obj.split(',')[0]
                        if(obj_type[:4] == 'data'):
                            # what kind of data
                            #print "okey, data"
                            a =  obj_type.split(':')[1]
                            if ';' in a: 
                                #print "okey, a in the mimetype"
                                mime_type, encoding = a.split(';')
                            else:
                                #print "no encoding"
                                mime_type = a
                                encoding = None
                            if encoding == 'base64':
                                #print "okey its base 64"
                                obj_d = obj.split(',')[1]
                                res = base64.decodestring(obj_d)
                                #print res[:50]
                            else:
                                raise ValueError('unknown encoding')
                        else:
                            "This is just a long string"
                            res = obj.encode('utf-8')
                        # print obj[:100]
                        gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
                        fh = gf.new_file()
                        fh.write(res)
                        fh.close()
                        return {"blob":1, "_id":fh._id}
                    else:
                        return obj
                else: 
                    return obj
                
                
            to_store = blob_storage( obj['object'] )
            to_store['site_id'] = site['_id'] 
            type = obj['type'] 
        
            if "_id" in to_store:
            
                req.storage.safe_update(type, to_store)
            else:
                req.storage.insert(type, to_store)
            
            
        
            return HttpResponse(json.dumps({"success": True, "_id": to_store['_id']} , default = json_util.default) )
        else:
            type = req.GET.get('type')
            r    = json.loads(req.GET.get('o','{}'), object_hook = json_util.object_hook )
            
            q = {'site_id': site['_id']}
            #print q
        
            if 'q' in r:
                q.update( r['q'] )
                #print q
                objs = req.storage.find(type, q)
            else:
                objs = req.storage.find(type, q)
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
        
            lst = list(data_updaters(type, lst))
        
            send = {'total_pages': total_pages,
                    'total_amount':total_amount,
                    'objects' : lst}
            
        
            #raise ValueError('STOP')
            return HttpResponse(json.dumps(send, default = json_util.default))



def blob_extruder(req, blob_id):
    
    gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
    f = gf.get( ObjectId(blob_id ))
    return HttpResponse( f )
    
    
class RegisterForm(forms.Form):
    hostname    = forms.RegexField(regex = r'^[\w-]+$', max_length = 30, label = _('Hostname'), error_messages={'invalid': _("Hostname cannot contain restricted symbols")}  )
    email       = forms.EmailField()
    password1 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password"))
    password2 = forms.CharField(widget=forms.PasswordInput,
                                label=_("Password (again)"))
    def __init__(self, *k, **kw):
        #print "INIT", kw, k
        print k, kw
        if 'request' in kw:
            self.request = kw['request']
            del kw['request']
            super (RegisterForm, self).__init__(*k, **kw)
        else:
            raise ValueError("No request provided")
                                
    """def clean_username(self):
        existing = User.objects.filter(username__iexact=self.cleaned_data['email'])
        
        if existing.exists():
            raise forms.ValidationError(_("A user with that email already exists. Login or restore your password."))
        else:
            return self.cleaned_data['username']      
    """                                 
    def clean(self):
        print "Validating"
        
        if 'password1' in self.cleaned_data and 'password2' in self.cleaned_data:
            if self.cleaned_data['password1'] != self.cleaned_data['password2']:
                raise forms.ValidationError(_("The two password fields didn't match."))
                
        if 'email' in self.cleaned_data:
            
            c = User.objects.filter(username = self.cleaned_data['email']).count()
            # raise ValueError(repr(c))
            if c > 0 :
                if 'email' in self._errors:
                    self._errors['email'].append("Email is already registered ")
                else:
                    self._errors['email'] = ErrorList(["Email is already registered "])
                
                raise forms.ValidationError(_("Checkout form"))
                    
        if 'hostname' in self.cleaned_data:
            full  = self.cleaned_data['hostname'] + '.' + settings.MY_BASE_HOST
            c = self.request.storage.findOne(accounts, {"hostname": full } )
            
            if c  :
                if 'hostname' in self._errors:
                    self._errors['hostname'].append("Hostname busy")
                else:
                    self._errors['hostname'] = ErrorList(["Hostname busy"])
                
                raise forms.ValidationError(_("Checkout form"))
                
                    
        return self.cleaned_data

        
class RegistrationView( FormView ):
    template_name = 'registration/registration_form.html'
    success_url = None
    form_class = RegisterForm
    #def get_form_class(self):
    #    return RegisterForm;
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
        hostname, email, password = cleaned_data['hostname'], cleaned_data['email'], cleaned_data['password1']
        
        hash_ = hashlib.md5(hostname + email + password + repr(datetime.datetime.now())).hexdigest()[:30]
        
        new_user = User.objects.create(username=email, email=email, last_name = hash_,  is_active = False , is_staff = False )
        
        new_user.set_password(password)
        new_user.save()
        
        new_user = authenticate(username=email,
                                password=password )
        login(self.request, new_user)
                    
        full = hostname +  '.' + settings.MY_BASE_HOST
        
        
        site = {"hostname":[ full ],
                "email" : email,
                "django_user_id" : new_user.id }
                
        s = self.request.storage.insert(accounts, site )
        
        
        d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
        
        r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)
        
        
        
        
        send_mail('Subject here', 'Here is the http://be-web.ru/activate/%s/ to activate account' % hash_ , 'info@be-web.ru',
            [ email ], fail_silently=True)
        
       
            
        return redirect(reverse("registration_complete"))
    def form_invalid(self, form):
        # print "form insvalid", repr(form.errors)
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
 
class NewHostView(TemplateView):
    def post(self, req, *k, **kw):
        if 'hostname' in req.POST:
            new_hostname = req.POST['hostname']
            full = new_hostname +  '.' + settings.MY_BASE_HOST
        
        
            site = req.storage.findOne(accounts, {'django_user_id': req.user.id} )
            """ 
            """
            if site:
                
                if len(site['hostname']) <= 5 :
                    site['hostname'].append(full)
                    s = req.storage.safe_update(accounts, site )
                    d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
                    r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)
            else:
                site = {"hostname":[ full ],
                        "email" : req.user.username,
                        "django_user_id" : req.user.id }
                        
                s = req.storage.insert(accounts, site )
                d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
                r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)
                
                
            
        return HttpResponseRedirect('/')
        
                                                    
urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'sop.views.home', name='home'),
    # url(r'^sop/', include('sop.foo.urls')),
    
    url(r'^admin/', base, {'is_admin' : True} ),
    url(r'^data/$', data_connector),
    url(r'^data/delete/$', data_deleter),
    
    
    
    url(r'^blob/(?P<blob_id>[a-zA-Z0-9].*)/', blob_extruder),

    url(r'^a/(?P<app_name>.*)/', get_app),
    url(r'^ad/(?P<app_name>.*)/', get_app_data),
    
    # url('^p/(?P<page_name>[a-zA-Z0-9].*)/', base),
    # url(r'^register/', 'registration.views.register', {'form': RegistrationFormUniqueEmail}, name='registration_register'),
    url(r'^register/$', RegistrationView.as_view(), name='registration_register'),
    url(r'^activate/(?P<activation_key>\w+)/$',ActivationView.as_view(), name='registration_activate'),
    
    url(r'^register/new_host/', NewHostView.as_view(), name = 'registration_addhost' ),
    
    # url(r'^register/closed/', TemplateView.as_view(template_name='registration/registration_closed.html'),  name='registration_disallowed' ),
    url(r'^register/complete/', TemplateView.as_view(template_name='registration/registration_complete.html'), name='registration_complete' ),
    url(r'^activate/complete/$',TemplateView.as_view(template_name='registration/activation_complete.html'),name='registration_activation_complete'),
    
    url(r'^auth/login/', 'django.contrib.auth.views.login', {'template_name':'registration/auth.html'} , name='login'),
    url(r'^auth/logout/', 'django.contrib.auth.views.logout', {'template_name':'registration/logout.html'}, name ='logout' ),

    #url(r'^auth/forgot_passwd/', )
    
    
    url(r'^$', base)
    
    #url('^(?P<page_name>)[a-z][A-Z][0-9].*)$', base)
    
    
    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
