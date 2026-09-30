FROM openresty/openresty:1.31-alpine-fat

ARG MYAUTH_LUA_VERSION

RUN echo $MYAUTH_LUA_VERSION

RUN apk update --allow-untrusted
RUN apk add git gcc 
RUN /usr/local/openresty/luajit/bin/luarocks install myauth $MYAUTH_LUA_VERSION 
RUN /usr/local/openresty/luajit/bin/luarocks install nginx-lua-prometheus 0.20201218
