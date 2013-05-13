from django.conf.urls.defaults import patterns, include, url

from django.http import HttpResponseRedirect,HttpResponse, Http404
from django.shortcuts import render_to_response
from django.core.context_processors import csrf
from django.conf import settings
import json,gridfs,base64
from bson import json_util
from bson import ObjectId
# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

def _my_base(req):
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
        c = {}
        c.update(csrf(req))
        
        return render_to_response("main_page.html", c)


def site_view(site, req, *k, **kw):
    if "pages" not in site:
        return HttpResponseRedirect('/admin/')
        
    pn = kw.get('page_name', None)
    
    page = site['pages'].get(pn, None)
    if page is None:
        raise Http404("Page not found")
    else:
        c = {'args':k,
             "kwargs":kw,
             "get" : dict(req.GET)}
        c.update(csrf(req))
        return render_to_response("templates/page.html", c)



def base(req, *k, **kw):
    
    host = req.META['HTTP_HOST']
    bh, port = host.split(':')
    
    if bh == settings.MY_BASE_HOST:
        return _my_base(req,*k,**kw)
    else:
        site = req.storage.findOne("general_sites", {"hostname": host})
        #raise IndexError("S")
        if site:
            
            return site_view(site,req, *k, **kw)
        else:
            
            return HttpResponseRedirect("http://" + settings.MY_BASE_HOST + ":" + port + "/")

def get_app(req, app_name = None):
    return HttpResponse("{init:function(to){ this.to= to},draw: function(){ $('<div>').text('this is an example app').appendTo( this.to) }}", mimetype="text/plain")

def get_app_data(req,app_name):
     return HttpResponse("{}", mimetype="text/plain")
MAX_NON_BLOB = 65536
def data_connector(req):
    if req.META['REQUEST_METHOD'] == 'POST':
        # data = req.POST.get('object')
        #type = req.POST.get('type')
        obj =  json.loads( req.POST.get('x-data') )
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
                        res = obj
                    print obj[:100]
                    gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
                    fh = gf.new_file()
                    fh.write(res)
                    fh.close()
                    return {"blob":1, "_id":fh._id}
                else:
                    return obj
            else: 
                return obj
                    
                
                
        to_store = blob_storage(obj['object'] )
        type = obj['type'] 
        req.storage.insert(type, to_store)
        
        return HttpResponse(json.dumps({"success": True}) )
    else:
        type = req.GET.get('type')
        r    = json.loads(req.GET.get('o','{}'))
        
        objs = req.storage.find(type)
        total_amount = objs.count()
        
        
        if 'p' in r:
            cur_page = r['p']['current_page']
            per_page = r['p']['per_page']
        else:
            cur_page = 0
            per_page = 100
        total_pages = total_amount / per_page + (1 if total_amount % per_page else 0)
        beg  = cur_page * per_page
        fin  = beg + per_page
        lst = list(objs[beg:fin])
        
        send = {'total_pages': total_pages,
                'total_amount':total_amount,
                'objects' : lst}
            
        
        #raise ValueError('STOP')
        return HttpResponse(json.dumps(send, default = json_util.default))


def blob_extruder(req, blob_id):
    
    gf = gridfs.GridFS(req.storage.conn, req.storage.get_collection("blobs"))
    f = gf.get( ObjectId(blob_id ))
    return HttpResponse( f )
    
urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'sop.views.home', name='home'),
    # url(r'^sop/', include('sop.foo.urls')),
    
    url(r'^admin/', include('constructor.urls')),
    url(r'^data/', data_connector),
    #url(r'^types/', types_connector),
    url(r'^blob/(?P<blob_id>[a-zA-Z0-9].*)/', blob_extruder),

    url(r'^a/(?P<app_name>.*)/', get_app),
    url(r'^ad/(?P<app_name>.*)/', get_app_data),
    
    url('^p/(?P<page_name>[a-zA-Z0-9].*)/', base),
    url('^$', base)
    
    #url('^(?P<page_name>)[a-z][A-Z][0-9].*)$', base)
    
    
    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
