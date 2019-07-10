#!/bin/bash -e

read -p 'Name DB: ' dbname
read -p 'User DB: ' dbuser
read -p 'Password: ' dbpass

if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${dbuser}@localhost IDENTIFIED BY '${dbpass}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
 
else
    echo "Please enter root user MySQL password!"
    read rootpasswd
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${dbuser}@localhost IDENTIFIED BY '${dbpass}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi