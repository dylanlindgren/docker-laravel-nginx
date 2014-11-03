#!/bin/bash
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf
sed -i "s/%fpm-ip%/$FPM_PORT_9000_TCP_ADDR/" /etc/nginx/nginx.conf
exec /usr/sbin/nginx
