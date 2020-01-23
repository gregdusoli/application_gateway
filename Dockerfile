FROM nginx:alpine

COPY ./nginx/config/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/config/proxy.conf /etc/nginx/proxy.conf
COPY ./nginx/config/fastcgi.conf /etc/nginx/fastcgi.conf
COPY ./nginx/config/mime.types /etc/nginx/mime.types
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# docker build -t registry.gitlab.com/findata-repo/docker/nginx-alpine .