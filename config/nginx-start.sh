#!/bin/bash
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf

cp ${DATA_ROOT:-/data}/${NGINX_VHOSTS} /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

sed -i "s/%fastgci-ip%/$PHP_PORT_9000_TCP_ADDR/" /etc/nginx/nginx.conf
sed -i "s/%data-root%/${DATA_ROOT:-/data}/" /etc/nginx/nginx.conf
exec /usr/sbin/nginx
