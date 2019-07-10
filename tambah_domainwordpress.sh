#!/bin/bash -e

uri='$uri'
args='$args'
err='"public, max-age=31536000, immutable"'

echo "Masukkan nama app dan domain."
read -p 'Name app: ' name_app
echo "Domain layer pisahkan dengan spasi setelah nama_domain"
read -p 'Nama domain: ' name_domain

sudo echo "server {
  listen 80;
  listen [::]:80;
  
  root /var/www/html/$name_app;
  
  index index.php index.html index.htm index.nginx-debian.html;
  
  server_name $name_domain;
  location / {
   try_files $uri/ /index.php?$args;
  }
  
  location ~ \.php$ {
   try_files $uri =404;
   fastcgi_split_path_info ^(.+\.php)(/.+)$;
   fastcgi_pass unix:/run/php/php5.6-fpm.sock;
   fastcgi_index index.php;
   include fastcgi.conf;
   fastcgi_read_timeout 300;
  }
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|eot|otf|ttf|woff|txt|xsl)$ {
   add_header Access-Control-Allow-Origin *;
   add_header Cache-Control $err; access_log off;
   log_not_found off;
  }
 
  location = /robots.txt {
   access_log off;
   log_not_found off;
  }
  location ~ /\. {
  deny all;
  access_log off;
  log_not_found off;
  }
}" > /etc/nginx/sites-available/$name_app

sudo ln -s /etc/nginx/sites-available/$name_app /etc/nginx/sites-enabled

cd /var/www/html

sudo wget https://wordpress.org/latest.tar.gz /var/www/html

tar -xzvf latest.tar.gz

mv wordpress $name_app

rm -f latest.tar.gz

chown -R www-data:www-data /var/www

service nginx restart