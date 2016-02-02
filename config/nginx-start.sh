#!/bin/bash
NGINX_VHOSTS=${NGINX_VHOSTS:-/data/vhosts}

rm /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
cp $NGINX_VHOSTS /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

#iterate though all the env vars and replace %ENV% with the value
printenv | while read envdef; do #iterate over all env vars
    key=${envdef%=*} # extract the env key name

    # replace all instances of %KEY% with the relevant environment value
    sed -i "s|%$key%|${!key}|" /etc/nginx/sites-available/*.conf
    sed -i "s|%$key%|${!key}|" /etc/nginx/nginx.conf # replace all instances of %KEY% with the value
done

cat /etc/nginx/sites-available/*.conf

exec /usr/sbin/nginx
