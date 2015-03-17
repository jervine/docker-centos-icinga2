# docker-centos-icinga2
## Icinga2 and Icinga2 web on CentOS docker image

This docker image creates a latest CentOS dokcer contianer runinng Apache2, MariaBD, and Icinga2 with Icinga Web 2. You should supply an enrivonment variable 'TZ' when the container is first run to set the correct timezone in /etc/php.ini - otherwise a default timezone of UTC is used:

    docker run -d -e TZ="Europe/London" -p 80:80 -p 443:443 jervine/docker-centos-icinga2

Optionally, the /etc/icinga2, /etc/icingaweb2, and /var/lib/mysql directories can be mapped from a local filesystem with the -v argument.

When first spun up, the web interface can be configured via http://\<docker host\>/icinga2web/setup - you will need the token that was created during initialisation, and this can be found by looking at the container logs:

    docker logs <container name> | grep token
