FROM openresty/openresty:1.15.8.3-centos

RUN yum update -y
RUN yum install -y curl-devel gcc git

RUN /usr/local/openresty/luajit/bin/luarocks install luasocket
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-test
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-prettycjson

ENTRYPOINT resty -Ilib --errlog-level error /test.lua 