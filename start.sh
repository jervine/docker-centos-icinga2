#!/bin/bash
##
## Start up script for Icinga2 on CentOS docker container
##

## Set up the correct ownership of any directories imported into the container from the host
chown -R mysql:mysql /var/lib/mysql
chown -R icinga:icinga /etc/icinga2
chown -R apache:icingaweb2 /etc/icingaweb2
chown root:icingaweb2 /etc/icingaweb2


## Set up basic Icinga2 configuration/features
# Enable feature: ido-mysql
if [[ -L /etc/icinga2/features-enabled/ido-mysql.conf ]]; then echo "Symlink for /etc/icinga2/features-enabled/ido-mysql.conf exists already...skipping"; else ln -s /etc/icinga2/features-available/ido-mysql.conf /etc/icinga2/features-enabled/ido-mysql.conf; fi

# Enable feature: checker
if [[ -L /etc/icinga2/features-enabled/checker.conf ]]; then echo "Symlink for /etc/icinga2/features-enabled/checker.conf exists already... skipping"; else ln -s /etc/icinga2/features-available/checker.conf /etc/icinga2/features-enabled/checker.conf; fi

# Enable feature: mainlog
if [[ -L /etc/icinga2/features-enabled/mainlog.conf ]]; then echo "Symlink for /etc/icinga2/features-enabled/mainlog.conf exists already... skipping"; else ln -s /etc/icinga2/features-available/mainlog.conf /etc/icinga2/features-enabled/mainlog.conf; fi

# Enable feature: command >> /dev/null
if [[ -L /etc/icinga2/features-enabled/command.conf ]]; then echo "Symlink for /etc/icinga2/features-enabled/command.conf exists already...skipping"; else ln -s /etc/icinga2/features-available/command.conf /etc/icinga2/features-enabled/command.conf; fi

# Enable feature: livestatus >> /dev/null
if [[ -L /etc/icinga2/features-enabled/livestatus.conf ]]; then echo "Symlink for /etc/icinga2/features-enabled/livestatus.conf exists already...skipping"; else ln -s /etc/icinga2/features-available/livestatus.conf /etc/icinga2/features-enabled/livestatus.conf; fi



## The mariadb instance is installed and empty directories are created as part of the container. This section performs the mysql_secure_installation steps.

# Start up the mariadb instance:
mysqld_safe --basedir=/usr --nowatch

# Make sure that NOBODY can access the server without a password - to be updated with a variable for a password ***
mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"

# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"

# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"

# Kill off the demo database
mysql -e "DROP DATABASE test"

# Setting up the icinga database - need to change the icinga user password to use a variable at some point ***
(
    echo "CREATE DATABASE IF NOT EXISTS icinga;"
    echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga.* TO 'icinga'@'localhost' IDENTIFIED BY 'icinga';"
    echo "quit"
) |
mysql
mysql -f icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql

# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param


## Initialising the icingaweb2 configuration
if [[ -L /etc/icingaweb2 ]];
  then echo "Icinga2 web configuration directory already exists...skipping"
else
  cd /usr/share/icingaweb2
  ./bin/icingacli setup config directory
  ./bin/icingacli setup token create
fi


## Start up icinga2 and apache web server daemons (maybe to be replaced with supervisor at some point)
/usr/sbin/icinga2 daemon -d -e /var/log/icinga2/error.log
/usr/sbin/httpd -k start