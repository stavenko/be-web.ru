# -*- coding:utf-8 -*-
import re
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
from django.core.mail import send_mail, EmailMessage
from django.contrib.auth import authenticate, login
from django.views.decorators.http import condition
from django.conf import settings
from bson import json_util
from bson import ObjectId
from django import forms
from powerdns import models as pmodels
import dns.resolver
import json, gridfs, base64, hashlib, datetime

import bson,zlib

    

try:
    from bs4 import BeautifulSoup as bs
except ImportError as e:
    from BeautifulSoup import BeautifulSOAP as bs




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

email_re = r"^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$"
e_re = re.compile(email_re)

accounts = "accounts"
sites    = 'sites'
redirect = HttpResponseRedirect  

siting_roles = ['admin','guest']
default_role = 'guest'

top_roles = {sites:{'view': ['admin','guest'],
                    'add': ['admin'],
                    'del':['admin']},
             'pattern':{'view': ['admin','guest'],
                        'add':  ['admin'],
                        'del':  ['admin'] },
            'invite': {'view':[],
                       'add':['admin'],
                       'del':[]}
                    }

def _get_current_roles(req, acc_site = None):
    # Хозяин сайта
    #  Всех остальных ищем в текущем сайте - может быть и есть доступ
    site = _get_current_site_inst(req, site = acc_site)
    user = req.user.username
    
    
    if not site: # and acc_site['django_user_id'] == req.user.id: 
        roles = []
    else:
        roles = dict([(r['user'],r['roles']) for r in  site.get('Roles',[])]).get(user,[])
    
    if acc_site['django_user_id'] == req.user.id and 'admin#generic.' + settings.MY_MAIN_SITE not in roles:
        roles.append('admin' + '#generic.' + settings.MY_MAIN_SITE)
    #raise ValueError('?')
    
    return roles
def _get_role_email(req, site, role):
    aasite = _get_current_site_inst(req, site)
    for r in aasite.get('Roles', []):
        print role, r
        if role in r['roles']:
            return r['user']
    
def getApplicationRoles(req, app_name):
    application_roles = req.storage.findOne('application', {'app_name': app_name}, {'data':1, 'default_role':1})
    return application_roles or {};

def _get_datatype_role(req, datatype):
    name,app_name = datatype.split('@')
    
    if app_name != 'generic.' + settings.MY_MAIN_SITE:
        app = getApplicationRoles(req, app_name)
        type_roles = app.get('data', {}).get(name, {'view':[],'add':[],'del':[]})
        def_role = app.get('default_role', default_role)
    else:
        type_roles = top_roles[name]
        def_role = default_role
    #raise IndexError('#')
    return {'roles':type_roles,'default_role': def_role, 'application': app_name }
    
def check_roles(req, datatype, perm, site = None):
    if not site:
        site = _get_current_site(req)
    
    site_roles = _get_current_roles(req, acc_site = site)
    roles = _get_datatype_role(req, datatype)
    
    #if not site_roles:
    site_roles.append(roles['default_role'] +'#' + roles['application'] )
        
    rl = roles['roles'][perm]
    pre_checker = [ (r + '#' + roles['application'] ) for r in rl]
    checker = [ ((r + '#' + roles['application']) in site_roles) for r in rl]
    #raise IndexError("!")
    return any(checker)
    
    

def _my_base(req, *k, **kw):
    return HttpResponseRedirect("http://" + settings.MY_MAIN_SITE + "/")

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
        return  HttpResponseRedirect('/auth/login/') # render_to_response("main_page.html", c)
    
def site_view(site, req, *k, **kw):
    escaped = req.GET.get('_escaped_fragment_', None)
    if escaped is not None:
        # send cached data to google or yandex
        site = _get_current_site(req, with_cache = True)
        
        html = site.get('cache',{}).get(escaped, '')
        # soup=bs(html)                #make BeautifulSoup
        # prettyHTML=soup.prettify()
        return HttpResponse(html)
        
    site['id'] = site['_id']
    c = RequestContext(req)
    c['site'] = site
    return render_to_response("constructor/displayer_page.html", c)
    
def site_edit(site, req, *k, **kw):
    c = RequestContext(req)
    is_debug = settings.DEBUG
    print req.user
    if  check_roles(req, sites + '@generic.'  + settings.MY_MAIN_SITE, 'add', site = site):
        site['id'] = site['_id']
        c['site'] = site
        return render_to_response("constructor/constructor_page.html", c)
    else:
        # Try to redirect at the base admin at first
        base = site['hostname'][0]
        current = req.META['HTTP_HOST']
        if base != current:
            return HttpResponseRedirect("http://" + base + "/admin/")
        return HttpResponseRedirect('/auth/login/')

def _get_current_site(req, with_cache = False):
    host = req.META['HTTP_HOST']
    if with_cache:
        fields = {'site_id':1, 'hostname':1, 'django_user_id':1, 'cache' : 1, 'favicon': 1}
    else:
        fields = {'site_id':1, 'hostname':1, 'django_user_id':1, 'favicon': 1}
    if ':' in host:
        bh, port = host.split(':')
    else:
        bh = host
        port = ''
    if bh == settings.MY_BASE_HOST:
        return None
    else:
        site = req.storage.findOne(accounts, {"hostname": host}, fields )
        
        return site
def _is_my_site(req, site):
    return site['django_user_id'] == req.user.id
    
def _get_current_site_inst(req, site=None):
    
    if site == None:
        acc_site = _get_current_site(req)
    else:
        acc_site = site
    q = {'site_id': acc_site['_id']}
    site = req.storage.findOne(sites, q)
    if site:
        if 'Roles' not in site and _is_my_site(req, acc_site ):
            # Здесь мы убеждены, что это наш личный сайт, иначе он бы не достался нам через _get_current_site для его сохранения мы можем впихнуть нас в роль админа насильно
            site['Roles'] = [ {'user':req.user.username,  "roles": ['admin#generic.' + settings.MY_MAIN_SITE]} ]
            req.storage.safe_update(sites, site)
        
    return site

def base(req, *k, **kw):
    
    host = req.META['HTTP_HOST']

    if host == settings.MY_BASE_HOST:
        return _my_base(req,*k,**kw)
    else:
        site = req.storage.findOne(accounts, {"hostname": host})
        if site:
            if kw.get('is_admin', False) :
                return site_edit(site, req, *k, **kw)
            else:
                return site_view(site, req, *k, **kw)
        else:
            return HttpResponseRedirect("http://" + settings.MY_BASE_HOST  + "/profile/")
                
MAX_NON_BLOB = 65536

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
    
    site = _get_current_site(req)
    app = req.storage.findOne('application', {'app_name': app_name, "site_id": site['_id'] })
    if app:
        app['is_own'] = True
        resp = HttpResponse(json.dumps(app, default = json_util.default))
        resp['Cache-Control'] = 'private'

        exp = (datetime.datetime.now() + datetime.timedelta(seconds= (60 * 5)) )
        resp['Expires'] = exp.strftime('%a %b %d %Y %H:%M:%S GMT+1200')
        print resp['Expires']
        return resp
    else:
        # search it in global index
        app_ix = req.storage.findOne('global_app_index', {'full_name': app_name} )
        print app_ix
        if app_ix:
            # application name in long name is a first parameter
            # generic.main.be-web.ru
            # theshop.main.be-web.ru
            #name = app_name.split('.',1)[0]
            app = req.storage.findOne('application', {'app_name': app_ix['full_name'], 'site_id': app_ix['site_id'] })
            app['is_own'] = False
            resp =  HttpResponse(json.dumps(app, default = json_util.default))
            resp['Cache-Control'] = 'private'

            exp = (datetime.datetime.now() + datetime.timedelta(seconds=60))
            resp['Expires'] = exp.strftime('%a, %d %b %Y %H:%M:%S')
            print resp['Expires']
            return resp
        else:
            raise ValueError("no such application")


def put_application_to_global_index(req, site, app):
    new_values = {}
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
        apps = list(req.storage.find('global_app_index', {'title': re.compile(iname) }))
    else:
        site = _get_current_site( req )
        apps = list(req.storage.find('application', {"site_id": site['_id'] }))

    return HttpResponse(json.dumps( {"apps": apps }, default = json_util.default  ))

def adding_application(req):
    
    def save_app(site, app, to_global = False):
        appl = req.storage.findOne('application', {'app_name': app['app_name'], "site_id": site['_id']})
        if appl:
            appl.update(app)
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
    
    if req.user.is_authenticated():
        app['site_id']  = site['_id']
        obj_id = save_app(site, app)
    else:
        auth_token = req.POST.get('crypt', "")
        
        username = req.POST.get('username', '')
        make_it_global = req.POST.get('make_it_global', False)
        print "lets do it global", make_it_global
        
        user = User.objects.get( username = username )
        my_cr = hashlib.md5(":".join([user.username, hashlib.md5(user.password).hexdigest() ])).hexdigest()
        
        if my_cr == auth_token:
            app['site_id'] = site['_id']
            obj_id = save_app(site, app, to_global = make_it_global )
        else:
            raise ValueError("Not authenticated")
        
    return HttpResponse(json.dumps({'success':True, "id": obj_id }, default = json_util.default ))
    
def blob_storage(req, obj):
    if isinstance(obj, dict):
        return dict([(k, blob_storage(req, v)) for (k,v) in obj.iteritems() ] )
    elif isinstance(obj, list):
        return [blob_storage(req, v) for v in obj ]

    elif isinstance(obj, (str,unicode)):
        if len(obj) > MAX_NON_BLOB:
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
            return {"blob":1, "_id":fh._id}
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
            is_unique = req.POST.get('is_unique', False)
            
            
            to_store = blob_storage(req, obj['object'] )
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
            print r
            q = {'site_id': site['_id']}
            if ('@' in type):
                mongo_db, app = type.split('@')
            else:
                mongo_db = type
        
            if check_roles(req, type, 'view', site = site):
                if 'q' in r:
                    q.update( r['q'] )
                    print q
                    objs = req.storage.find(mongo_db, q)
                else:
                    objs = req.storage.find(mongo_db, q)
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
    if req.META.get('HTTP_IF_NONE_MATCH', '') != f.md5:
        resp = HttpResponse( f , mimetype=mt if mt is not None else "text/plain")
        resp['ETag'] = f.md5
        return resp

    else:
        r = HttpResponse()
        r.status_code = 304
        return r

class RegisterMixture(forms.Form):
    def __init__(self, *k, **kw):
        if not hasattr(self, 'request'):
            if 'request' in kw:
                self.request = kw['request']
                del kw['request']
                super (RegisterMixture, self).__init__(*k, **kw)
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
            full = hostname +  '.' + settings.MY_BASE_HOST
            site = {"hostname":[ full ],
                    "email" : email,
                    "django_user_id" : new_user.id }
                
            s = self.request.storage.insert(accounts, site )
        
        
            d,is_created = pmodels.Domain.objects.get_or_create(name =settings.MY_BASE_HOST)
        
            r,is_c = pmodels.Record.objects.get_or_create(name = full, content= settings.MY_BASE_HOST, type = 'CNAME', domain = d)
        
        
        if settings.DEBUG:
            sender = 'vg.stavenko@yandex.ru'
        else:
            sender = 'info@be-web.ru'
        
        subj = 'Be-web registration confirmation'
        body = 'Please, click on the <a href="http://be-web.ru/activate/%s/">link</a> to activate account' % hash_ 
        recv  = [ email ]
        
        email = EmailMessage(subj, body, sender, recv )
        email.content_subtype = "html" 
        email.send()
       
            
        return redirect(reverse("registration_complete"))
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

            return HttpResponseRedirect("/auth/login/")

        if False:
            return HttpResponseRedirect("/auth/login/")
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
        <a href='http://be-web.ru/auth/restore_password/?key=%s'>Восстановить пароль</a> """ % key
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
        return HttpResponseRedirect('/profile/')
        
        
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
        body = sjs[i]['body']
        S = bs(body)
        html = u"<html> <head>%s %s</head> %s</html>" %( head, DS, body)
        key = i[2:]
        cache[key] = html
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
            return HttpResponse(json.dumps({'domain_confirm': False }))

    except Exception as e:
        #print e
        return HttpResponse(json.dumps({'domain_confirm': False }))

def robots_txt(req):
    robots = """User-agent: *
Disallow: /admin/
Disallow: /static/
Disallow: /a/
Disallow: /data/
Disallow: /site_cache/
Disallow: /blob/
Disallow: /app/
Disallow: /email/
Disallow: /check_domain/
Disallow: /profile/
Disallow: /register/
Disallow: /auth/


"""
    return HttpResponse(robots, mimetype = "text/plain")

def favicon(req):
    s = _get_current_site(req)
    if s is None:
        return HttpResponse ('')
    fvb64 = s.get('favicon', '')

    if fvb64:
        b64 = fvb64.split(',')[1]
        res = base64.decodestring(b64)
        #raise ValueError(res)

        return HttpResponse(res, mimetype="image/vnd.microsoft.icon")
    else:
        return HttpResponse("")


urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'sop.views.home', name='home'),
    # url(r'^sop/', include('sop.foo.urls')),
    
    url(r'^admin/', base, {'is_admin' : True} ),
    url(r'^data/$', data_connector),
    url(r'^data/delete/$', data_deleter),
    
    url(r'^site_cache/$', site_cacher),
    
    
    
    url(r'^blob/(?P<blob_id>[a-zA-Z0-9].*)/', blob_extruder),

    url(r'^a/(?P<app_name>.*)/', get_application),
    url(r'^app/add/', adding_application),
    url(r'^app/list/', find_application),

    
    url(r'^email/', send_email),
    url(r'^check_domain/', check_domain),
    url(r'^profile/', profile_page),
    url(r'robots.txt', robots_txt),
    url(r'favicon.ico', favicon),

    
    url(r'^register/$', RegistrationView.as_view(), name='registration_register'),
    url(r'^register/no_site/$', RegistrationView.as_view( no_site = True ), name='registration_register', ),
    
    url(r'^activate/(?P<activation_key>\w+)/$',ActivationView.as_view(), name='registration_activate'),
    
    url(r'^register/new_host/', NewHostView.as_view(), name = 'registration_addhost' ),
    
    # url(r'^register/closed/', TemplateView.as_view(template_name='registration/registration_closed.html'),  name='registration_disallowed' ),
    url(r'^register/complete/', TemplateView.as_view(template_name='registration/registration_complete.html'), name='registration_complete' ),
    url(r'^activate/complete/$',TemplateView.as_view(template_name='registration/activation_complete.html'),name='registration_activation_complete'),
    
    url(r'^auth/login/', 'django.contrib.auth.views.login', {'template_name':'registration/auth.html'} , name='login'),
    url(r'^auth/logout/', 'django.contrib.auth.views.logout', {'template_name':'registration/logout.html'}, name ='logout' ),

    url(r'^auth/forgot_passwd/', forgot_password, name='forgot_password'),
    url(r'^auth/restore_password/', restore_password, name='restore_password'),

    
    url(r'^$', base)
    
    #url('^(?P<page_name>)[a-z][A-Z][0-9].*)$', base)
    
    
    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
