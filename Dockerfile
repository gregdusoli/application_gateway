FROM nginx:alpine

WORKDIR /server

COPY ./nginx/config/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/config/proxy.conf /etc/nginx/proxy.conf
COPY ./nginx/config/fastcgi.conf /etc/nginx/fastcgi.conf
COPY ./nginx/config/mime.types /etc/nginx/mime.types
COPY ./nginx/conf.d/ /etc/nginx/conf.d/
COPY ./nginx/upstreams/ /etc/nginx/upstreams/
COPY ./nginx/www/ /var/www/
COPY ./nginx/ssl/ /etc/ssl/

# docker build -t registry.gitlab.com/findata-repo/docker/nginx-alpine .