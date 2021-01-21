FROM openresty/openresty:1.15.8.3-centos

RUN yum -y install git gcc \
  && /usr/local/openresty/luajit/bin/luarocks install base64 1.5 \
  && /usr/local/openresty/luajit/bin/luarocks install lua-resty-jwt 0.2.2 \
  && /usr/local/openresty/luajit/bin/luarocks install lua-resty-test 0.1 \
  && /usr/local/openresty/luajit/bin/luarocks install luafilesystem 1.8.0
