FROM gliderlabs/alpine:3.3

ENV NGINX_VERSION release-1.9.9

VOLUME ["/etc/nginx"]

RUN apk --no-cache add git \
gcc \
g++ \
make \
pcre-dev \
openssl-dev \
openldap-dev \
&& mkdir /var/log/nginx \
&& mkdir /var/run/nginx \
&& cd ~ \
&& git clone https://github.com/kvspb/nginx-auth-ldap.git \
&& git clone https://github.com/nginx/nginx.git \
&& cd ~/nginx \
&& git checkout tags/${NGINX_VERSION} \
&& ./auto/configure \
--add-module=/root/nginx-auth-ldap \
--with-http_ssl_module \
--conf-path=/etc/nginx/nginx.conf \
--sbin-path=/usr/sbin/nginx \
--pid-path=/var/run/nginx/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
&& make install \
&& cd .. \
&& rm -rf nginx-auth-ldap \
&& rm -rf nginx \
&& wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/v0.0.4/dockerize-linux-amd64-v0.0.4.tar.gz \
&& tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
&& rm -rf /tmp/dockerize.tar.gz \
&& apk del git \
gcc \
g++ \
make

EXPOSE 443

ENTRYPOINT ["dockerize"]
CMD ["-stdout","/var/log/nginx/access.log","-stderr","/var/log/nginx/error.log","/usr/sbin/nginx","-g","daemon off;"]
