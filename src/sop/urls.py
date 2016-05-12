# -*- coding:utf-8 -*-
import re
from django.conf.urls.defaults import patterns, include, url

from django.http import HttpResponseRedirect,HttpResponse, Http404
from django.template import RequestContext
from django.shortcuts import render_to_response
from django.conf import settings
import json, gridfs, base64, hashlib, datetime
from bson import json_util
from constructor.utils import _get_current_site, accounts,sites,check_roles,get_application_obj
    

try:
    from bs4 import BeautifulSoup as bs
except ImportError as e:
    from BeautifulSoup import BeautifulSOAP as bs


last_modified_dateformat = '%a %b %d %Y %H:%M:%S GMT'

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

    

def _my_base(req, *k, **kw):
    return HttpResponseRedirect("http://" + settings.MY_MAIN_SITE + "/")

def site_view(site, req, *k, **kw):
    escaped = req.GET.get('_escaped_fragment_', None)
    site = _get_current_site(req, with_cache = True)
    if escaped is not None:
        # send cached data to google or yandex

        html = site.get('cache',{}).get(escaped, {}).get("html", "")
        return HttpResponse(html)
    
        
    site['id'] = site['_id']
    c = RequestContext(req)
    c['site'] = site
    c['main_page'] = site.get('cache',{}).get('',{})
    S = req.storage.findOne(sites, {'site_id':site['id']})
    c['site_object'] = json.dumps(S, default = json_util.default)
    apps = S['_Apps']
    apps = dict([(a,get_application_obj(req, a)) for a in apps])
    c['app_eggs'] = json.dumps(apps, default = json_util.default)
    pats = req.storage.find('pattern', {'site_id': site['id']})
    pats = dict([(str(p['_id']),p) for p in pats])
    c['patterns']    =  json.dumps(pats, default = json_util.default)
    # DIRTY OPTIMIZATION HACK
    
    displayer_path = settings.DISPLAYER_PATH
    cont = open(displayer_path,'r').read()
    c['constructor_script'] = cont

    
    return render_to_response("constructor/displayer_page.html", c)
    
def site_edit(site, req, *k, **kw):
    c = RequestContext(req)
    is_debug = settings.DEBUG
    if  check_roles(req, sites + '@generic.'  + settings.MY_MAIN_SITE, 'add', site = site):
        site['id'] = site['_id']
        c['site'] = site
        
        S = req.storage.findOne(sites, {'site_id':site['id']})
        c['site_object'] = json.dumps(S, default = json_util.default)
        apps = S['_Apps']
        apps = dict([(a,get_application_obj(req, a)) for a in apps])
        c['app_eggs'] = json.dumps(apps, default = json_util.default)
        pats = req.storage.find('pattern', {'site_id': site['id']})
        pats = dict([(str(p['_id']),p) for p in pats])
        c['patterns']    =  json.dumps(pats, default = json_util.default)
        return render_to_response("constructor/constructor_page.html", c)
    else:
        # Try to redirect at the base admin at first
        base = site['hostname'][0]
        current = req.META['HTTP_HOST']
        if base != current:
            return HttpResponseRedirect("http://" + base + "/admin/")
        return HttpResponseRedirect('/_/auth/login/')


def base(req, *k, **kw):
    
    host = req.META['HTTP_HOST']
    if host == settings.MY_BASE_HOST:
        return _my_base(req,*k,**kw)
    else:
        site = req.storage.findOne(accounts, {"hostname": host})

        if site:
            #print kw
            if kw.get('is_admin', False) :
                return site_edit(site, req, *k, **kw)
            else:
                #print ">>>>"
                return site_view(site, req, *k, **kw)
        else:
            return HttpResponseRedirect("http://" + settings.MY_BASE_HOST  + "/_/profile/")
                


def robots_txt(req):
    robots = """User-agent: *
Disallow: /admin/
Disallow: /static/
Disallow: /_/


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
    url(r'^$', base),

    url(r'^admin/', base, {'is_admin' : True} ),
    url(r'robots.txt', robots_txt, name = "robots_txt"),
    url(r'favicon.ico', favicon, name = "favicon_txt"),

    


    #url('^(?P<page_name>)[a-z][A-Z][0-9].*)$', base)
    
    
    # Uncomment the admin/doc line below to enable admin documentation:
    url(r'^_/', include('constructor.urls') )

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
