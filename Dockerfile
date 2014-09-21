FROM centos:centos7

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

WORKDIR /tmp

# Install prerequisites for Nginx compile
RUN yum install -y \
    wget \
    tar \
    openssl-devel \
    gcc \
    gcc-c++ \
    make \
    zlib-devel \
    pcre-devel \
    gd-devel \
    krb5-devel \
    git

# Download Nginx and Nginx modules source
RUN wget http://nginx.org/download/nginx-1.6.1.tar.gz -O nginx.tar.gz && \
    mkdir /tmp/nginx && \
    tar -xzvf nginx.tar.gz -C /tmp/nginx --strip-components=1 &&\
    git clone https://github.com/stnoonan/spnego-http-auth-nginx-module.git nginx/spnego-http-auth-nginx-module

# Build Nginx
WORKDIR /tmp/nginx
RUN ./configure \
    --user=nginx \
    --with-debug \
    --group=nginx \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_spdy_module \
    --with-pcre \
    --with-http_image_filter_module \
    --with-file-aio \
    --with-ipv6 \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --add-module=spnego-http-auth-nginx-module && \
    make && \
    make install

# Configure filesystem to support running Nginx
RUN adduser -c "Nginx user" --uid 2000 nginx && \
    setcap cap_net_bind_service=ep /usr/sbin/nginx

# Apply Nginx configuration
ADD config/nginx.conf /etc/nginx/nginx.conf

# This script gets the linked PHP-FPM container's IP and puts it into
# the upstream definition in the /etc/nginx/nginx.conf file, after which
# it launches Nginx.
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh && \
    chown nginx:nginx /opt/bin/nginx-start.sh /etc/nginx /etc/nginx/nginx.conf /var/log/nginx /usr/share/nginx

# DATA VOLUMES
RUN mkdir -p /data/www/
RUN mkdir -p /data/nginx/logs/
VOLUME ["/data/www"]
VOLUME ["/data/nginx/logs"]

# PORTS
EXPOSE 80
EXPOSE 443
USER nginx
ENTRYPOINT ["/opt/bin/nginx-start.sh"]
