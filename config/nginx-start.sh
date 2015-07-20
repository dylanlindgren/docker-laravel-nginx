#!/bin/bash
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf

cp ${DATA_ROOT:-/data}/${NGINX_VHOSTS} /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

sed -i "s/%fastgci-ip%/$PHP_PORT_9000_TCP_ADDR/" /etc/nginx/nginx.conf
sed -i "s|%data-root%|${DATA_ROOT:-/data}|" /etc/nginx/nginx.conf
sed -i "s|%data-root%|${DATA_ROOT:-/data}|" /etc/nginx/sites-available/*.conf

#iterate though all the env vars and replace %ENV% with the value
printenv | while read envdef; do #iterate over all env vars
    key=${envdef%=*} # extract the env key name
#    echo "%"$env"% = "${!env};

    sed -i "s|%$key%|${!key}|" /etc/nginx/sites-available/*.conf # replace all instances of %KEY% with the value
done

cat /etc/nginx/sites-available/*.conf

exec /usr/sbin/nginx
