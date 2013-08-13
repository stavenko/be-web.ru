#!/usr/bin/env python

import json
import urllib, urllib2, datetime
import cookielib

directory = "/Users/azl/Documents/workspace/be-web.ru/src/constructor/static/js/sop/"

apps = ["generic", 'theshop']

#def object_hook(k,v):
#    print k, v
js = "return this.Main(constr,appid)"

import hashlib

username = "stavenko@gmail.com"
LOCAL = False
MAKE_IT_GLOBAL = True;

if LOCAL:
    key_hash = 'ece2567c6348b81def04aa550c86a778' # localhost
    cookie_url = 'http://test.be-test.com:8000/'
    post_url   = 'http://test.be-test.com:8000/app/add/'
    
else:
    key_hash = '50360e1f4c3ee726b87f387b53c57c3b' # globalhost
    cookie_url = 'http://www.be-web.ru/'
    post_url   = 'http://www.be-web.ru/app/add/'
    



    
cookies = cookielib.LWPCookieJar()
handlers = [
    urllib2.HTTPHandler(),
    urllib2.HTTPSHandler(),
    urllib2.HTTPCookieProcessor(cookies)
    ]
opener = urllib2.build_opener(*handlers)
urllib2.install_opener(opener)

CSRF = ''
    
for app in apps:
    fname = directory + app + '.manifest'
    appfname = directory + app + '.js'
    manifest_fp = open(fname,'rt')
    contents = unicode(manifest_fp.read(), 'utf-8')
    # print contents;
    app_manifest = json.loads(contents)
    
    Main_contents = unicode(open(appfname, 'rt').read(), 'utf-8')
    
    main = {"is_function": True, "body": Main_contents, 'attr':'constr, appid' }
    app_manifest['Main'] = main
    app_manifest['getter'] = {'is_function':True, "attr" : "constr, appid", "body": js}

    auth_token = hashlib.md5( ":".join([username, key_hash])).hexdigest()
    
    if not CSRF:
        resp = urllib2.urlopen(cookie_url)
        CSRF =  resp.headers['set-cookie'].split(';')[0].split('=')[1]
    print CSRF

    req = urllib2.Request(post_url)
    data = {'username':username, 'crypt': auth_token, 
            'make_it_global': MAKE_IT_GLOBAL,
            'csrfmiddlewaretoken': CSRF, 
            'x-data': json.dumps(app_manifest)
    }

    req.add_data(urllib.urlencode(data))
    res = urllib2.urlopen(req)
