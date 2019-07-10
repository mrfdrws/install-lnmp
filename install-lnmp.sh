#!/bin/bash -e

#install nginx

sudo apt-get update

sudo echo "PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
LC_ALL="en_US.utf8"" > /etc/environment

yes | sudo apt-get install nginx

sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_backup

sudo echo /etc/nginx/sites-available/default

uri='$uri'
args='$args'

sudo echo "server {
  listen 80 default_server;

  listen [::]:80 default_server;
  root /var/www/html/default;
  index index.php index.html index.htm index.nginx-debian.html;
  server_name _;

  location / {
   try_files $uri/ /index.php?$args;
  }

  location = /robots.txt {
   try_files $uri/ /index.php?$args;
   access_log off;
   log_not_found off;
  }

 location ~ \.php$ {
  try_files $uri =404;
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  fastcgi_pass unix:/run/php/php5.6-fpm.sock;
  fastcgi_index index.php;
  include fastcgi.conf;
  fastcgi_read_timeout 300;
  }

 location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|eot|otf|ttf|woff|txt|xsl)$ {
  add_header Access-Control-Allow-Origin *;
  add_header Cache-Control "public, max-age=31536000, immutable"; access_log off;
  log_not_found off;
  }

 location ~ /\. {
  deny all;
  access_log off;
  log_not_found off;
  }
}" > /etc/nginx/sites-available/default


#install php + module

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


#install mysql 

yes | sudo apt-get install php5.6-mysql

yes | sudo apt-get install mysql-server

PURGE_EXPECT_WHEN_DONE=0


if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Check input params
#
if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
    CURRENT_MYSQL_PASSWORD=''
    NEW_MYSQL_PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
    CURRENT_MYSQL_PASSWORD="${1}"
    NEW_MYSQL_PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
    exit 1
fi


if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    aptitude -y install expect

fi

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"
expect \"root password?\"
send \"y\"
expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"n\"
expect \"Disallow root login remotely?\"
send \"n\"
expect \"Remove test database and access to it?\"
send \"n\"
expect \"Reload privilege tables now?\"
send \"n\"
expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
    aptitude -y purge expect
fi

exit 0
