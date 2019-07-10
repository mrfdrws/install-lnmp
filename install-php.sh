#!/bin/bash -e

sudo add-apt-repository -y ppa:ondrej/php

sudo apt-get update

yes | sudo apt-get install php5.6-fpm

yes | sudo apt-get install php5.6

yes | sudo apt-get install curl php5.6-curl php5.6-common php5.6-json php5.6-mbstring php5.6-gd php5.6-intl php5.6-xml php5.6-xmlrpc php5.6-imagick php5.6-redis php5.6-zip

sudo phpenmod mbstring

upload_max_filesize=240M
post_max_size=50M
max_execution_time=100
max_input_time=223

for key in upload_max_filesize post_max_size max_execution_time max_input_time
do
 sed -i "s/^\($key\).*/\1 $(eval echo = \${$key})/" /etc/php/5.6/fpm/php.ini
done

sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/5.6/fpm/php.ini

sed -i "s/;extension=php_mysqli.dll/extension=php_mysqli.dll/g" /etc/php/5.6/fpm/php.ini

sed -i "s/;extension=php_mysql.dll/extension=php_mysql.dll/g" /etc/php/5.6/fpm/php.ini

sed -i "s/;request_terminate_timeout = 0/request_terminate_timeout = 300/g" /etc/php/5.6/fpm/pool.d/www.conf
