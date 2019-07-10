#!/bin/bash -e

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

