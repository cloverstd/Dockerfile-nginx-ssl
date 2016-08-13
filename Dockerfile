FROM ubuntu:16.04
MAINTAINER cloverstd https://github.com/cloverstd

COPY aliyun.sources.list /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y build-essential libpcre3 libpcre3-dev zlib1g-dev

COPY . /tmp/source
RUN cd /tmp/source/nginx-1.9.7 && ./configure --add-module=../nginx-ct-1.2.0 --with-openssl=../openssl --with-http_v2_module --with-http_spdy_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module && \
    make && make install && rm -rf /tmp/source

# forward request and error logs to docker log collector
# from https://github.com/nginxinc/docker-nginx
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/nginx/logs/error.log

EXPOSE 80 443

#ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
