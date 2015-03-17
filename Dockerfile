FROM centos:latest
MAINTAINER Jonathan Ervine <jon.ervine@gmail.com>

RUN yum update -y &&  yum clean all
RUN yum install -y http://mirror.pnl.gov/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN rpm --import http://packages.icinga.org/icinga.key
RUN curl http://packages.icinga.org/epel/ICINGA-release.repo > /etc/yum.repos.d/ICINGA-release.repo
RUN yum makecache

RUN yum install -y icinga2 nagios-plugins-all git mariadb-server icinga2-ido-mysql httpd php php-intl php-theseer-fDOMDocument php-gd php-pecl-imagick php-pdo php-ZendFramework-Db-Adapter-Pdo-Mysql

RUN /usr/libexec/mariadb-prepare-db-dir
RUN usermod -a -G icingacmd apache
RUN git clone https://git.icinga.org/icingaweb2.git
RUN mv icingaweb2 /usr/share/icingaweb2
RUN cd /usr/share/icingaweb2; ./bin/icingacli setup config webserver apache --document-root /usr/share/icingaweb2/public > /etc/httpd/conf.d/icingaweb2.conf
RUN groupadd -r icingaweb2
RUN usermod -a -G icingaweb2 apache

ADD start.sh /sbin/start.sh
RUN chmod 755 /sbin/start.sh

VOLUME ["/etc/icinga2", "/etc/icingaweb2", "/var/lib/mysql"]

EXPOSE 80 443

ENTRYPOINT ["/sbin/start.sh"]
