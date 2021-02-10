FROM openresty/openresty:1.15.8.3-centos

ARG MYAUTH_LUA_VERSION

RUN echo $MYAUTH_LUA_VERSION

RUN yum -y install git gcc 
RUN /usr/local/openresty/luajit/bin/luarocks install myauth $MYAUTH_LUA_VERSION 
RUN /usr/local/openresty/luajit/bin/luarocks install nginx-lua-prometheus 0.20201218

COPY ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./nginx-log.conf /usr/local/openresty/nginx/conf/nginx-log.conf
COPY ./clear-log.cron /etc/cron.d/clear-log.cron
