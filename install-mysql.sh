#!/bin/bash -e

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