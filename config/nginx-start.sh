#!/bin/bash
cp /opt/etc/nginx.conf /etc/nginx/nginx.conf

export DATA_ROOT=${DATA_ROOT:-/data}

cp ${DATA_ROOT}/${NGINX_VHOSTS} /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

#export the current tcp ip address so configuration can forward the nginx service port to dependent services
export UPSTREAM_WEB_TCP_ADDR=$(ip -f inet -o addr show eth0 | cut -d\  -f 7 | cut -d/ -f 1)
#iterate though all the env vars and replace %ENV% with the value
printenv | while read envdef; do #iterate over all env vars
    key=${envdef%=*} # extract the env key name
#    echo "%"$env"% = "${!env};

    # replace all instances of %KEY% with the relevant environment value
    sed -i "s|%$key%|${!key}|" /etc/nginx/sites-available/*.conf
    sed -i "s|%$key%|${!key}|" /etc/nginx/nginx.conf # replace all instances of %KEY% with the value
done

cat /etc/nginx/sites-available/*.conf

exec /usr/sbin/nginx
