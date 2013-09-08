# -*- coding: utf-8 -*-
__author__ = 'azl'


from django.conf import settings
from django.http import HttpResponseRedirect

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



def _get_current_site(req, with_cache = False):
    host = req.META['HTTP_HOST']
    if with_cache:
        fields = {'site_id':1, 'hostname':1, 'django_user_id':1, 'cache' : 1, 'favicon': 1, 'cached_urls':1, 'textColors':1}
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