#!/bin/sh

mkdir /usr/local/lib/python2.7/dist-packages/run
chown www-data:www-data /usr/local/lib/python2.7/dist-packages/run
mysql -u root -e "create database if not exists beweb character set =\"utf8\";"
# mysql -u root -e "create database if not exists face_project character set =\"utf8\";"

django-admin syncdb --settings="sop.settings"
django-admin syncdb --database=powerdns --settings='sop.settings'

chmod +x /etc/init.d/sop.sh
update-rc.d sop.sh defaults
/etc/init.d/sop.sh restart
cd /etc/nginx/sites-enabled
ln -s ../sites-available/sop_nginx.conf

cd /var/www/src/constructor/static/
sudo mkdir /var/www/uploaded_files

sudo chown www-data:www-data /var/www/uploaded_files

sudo ln -s /usr/lib/python2.7/dist-packages/django/contrib/admin/static/admin/
/etc/init.d/nginx restart

