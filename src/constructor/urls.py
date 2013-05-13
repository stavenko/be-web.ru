# -*- coding: utf-8 -*-
'''
Created on 07.01.2013

@author: azl
'''
from django.conf.urls.defaults import patterns, include, url

# Uncomment the next two lines to enable the admin:
import views

from django.contrib import admin
admin.autodiscover()
# from general_service import UrlPatterns

#P = UrlPatterns(namespace = "os")


#P.add(r'^$', views.ConstructorPage.as_view(), name="constructor",label="Конструктор страниц")
#P.add(r'^a/((?P<year>\d{4}))$', views.ConstructorPage.as_view(), name="constructor",label="Конструктор страниц")




urlpatterns = patterns("", 
                       url(r'^$' ,views.ConstructorPage.as_view(), name="constructor"))
