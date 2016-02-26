FROM debian:jessie

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

# Install Nginx
RUN apt-get update -y && \
    apt-get install -y nginx

# Apply Nginx configuration
ADD config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default

# Nginx startup script
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh

RUN mkdir -p /data

ENTRYPOINT ["/opt/bin/nginx-start.sh"]