# -*- coding: utf-8 -*- 
'''
Created on 14.02.2013

@author: azl
'''
from django.db import connection
from django.conf import settings
from pymongo import Connection

class MongoConnection(object):
    def __init__(self, conn, collection_prefix = ''):
        self.conn = conn
        self.collection_prefix = collection_prefix
    def _get_col(self,s):
        return self.collection_prefix + s
    
    def insert(self, collection, object):
        if 'version' not in object:
            object['version'] = 0

        return self.conn[self._get_col(collection)] .insert(object)
    
    def save(self,collection, *k, **kw):
            return self.conn[self._get_col(collection)].save(*k, **kw)
        
    def update(self,collection, *k, **kw):
            if "try_count" in kw:
                del kw['try_count']
            if 'version' not in k[1]:
                k['version'] = 0
            return self.conn[self._get_col(collection)].update(*k, **kw)
        
    def makeNewInc(self, name):
        tries = 10
        while tries:
            c = self.findOne("counters", {'name':name})
            #num = c['number']
            if not c:
                c = {"name":name, 'number':1}
                res = self.insert("counters", c)
                return 1

            tries -= 1
            old_number = c['number']
            new_number = old_number + 1
            new_c = {"name":c['name'], "number":new_number} 
            
            res = self.update("counters",{"name":c['name'],"number":old_number}, new_c , w=settings.MONGO_UPDATE_LEVEL)
            if res['updatedExisting']:
                return c['number']
        raise ValueError("Could not get new number in counter %s" % name)
            
        
        
        
        
        
        
    def safe_update(self,collection,*k, **kw):
        
        if len(k) == 1:
            doc = k[0]
            if 'version' in doc:
                fq = {'version':doc['version'], "_id": doc['_id']}
            else:
                fq = { "_id": doc['_id']}

        else:
            fq = k[0]
            doc = k[1]
        
        if  "try_count" not in kw:
            kw['try_count'] = 10
        else:
            kw['try_count'] -= 1
            
        if "w" not in kw:
            kw['w'] =  settings.MONGO_UPDATE_LEVEL
        else:
            if kw['try_count'] < 0:
                if  kw.get('silent', True):
                    return (False, doc)
                raise ValueError("Cannot update database. Amount of tries reached it's limit.")
        old = self.findOne(collection, fq, {"_id":True, "version":True})
        q = {}
        
        if 'version' in old:
            q['version'] = old['version'] 
            
        q['_id']    = old['_id']
        doc['version'] = old.get('version',0) + 1
        # print q
        res = self.update(collection, q, doc, **kw)
        #print res
        if not res['updatedExisting']:
            return self.safe_update(collection, *k, **kw)
        else:
            return (True, doc)
    
    def find(self,collection, *k, **kw):
        return self.conn[self._get_col(collection)].find(*k, **kw)
    
    def findOne(self,collection, *k, **kw):
        return self.conn[self._get_col(collection)].find_one(*k, **kw)
    
    def remove(self,collection, *k, **kw):
        return self.conn[self._get_col(collection)].remove(*k, **kw)
    
    def map_reduce(self,collection, *k, **kw):
        print collection,k, kw
        return self.conn[self._get_col(collection)].map_reduce(*k, **kw)
        

    def get_collection(self, s):
        return self._get_col(s)

class MongoDBMiddleware(object):
    def process_request(self,request):
        if hasattr(connection, 'database'):
        
            db = connection.database
        else:
            host = settings.MONGO_HOST 
            db_name = settings.MONGO_DATABASE
            conn = Connection(host)
            db = conn[db_name]
        
        request.storage = MongoConnection(db) 
        return None
    
class AuthSessionHackMiddleware(object):
    def process_view(self, request, view_func, view_args, view_kwargs):
        addr = request.META['PATH_INFO']
        #print "I'M WORKING ON THAT"
        #print ("/oauth/complete/", addr)
        if "/oauth/complete/" in addr:
            basket = request.session.get('basket', {})
            response = view_func(request, *view_args, **view_kwargs )
            if basket:
                # Если во вьюхе все прошло гладко - ун ас новая пустая сессия
                request.session['basket'] = basket
            return response
        return None
                
        
        
        