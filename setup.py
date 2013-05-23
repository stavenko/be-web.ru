#!/usr/bin/env python
from distutils.core import setup



import os, sys

data_dirs=["src/sop/templates","src/constructor/static"]
data_files = []
for r in data_dirs:
    for (root, dirs, files) in os.walk(r):
        data_files.append( ("/var/www/" + root, [root + "/" + f for f in files] ) ) 

# print data_files
data_files.append(("/etc/init.d/", ["sop.sh"] ))
data_files.append(("/etc/nginx/sites-available/", ["sop_nginx.conf"] ))


#"""
setup(
    name='be-web',
    version='0.0.1',
    author='Vasiliy G. Stavenko',
    author_email='stavenko@gmail.com',
    package_dir={'':'src'},
    packages = ["constructor", 'sop'],
    data_files = data_files,
    scripts = ["sop_init.sh"],
    #scripts=['bin/stowe-towels.py','bin/wash-towels.py'],
    #url='http://pypi.python.org/pypi/TowelStuff/',
    license='LICENSE.txt',
    description='server stuff',
    long_description=open('README').read(),
    
)
#"""
