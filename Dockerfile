FROM ubuntu:16.04
MAINTAINER cloverstd https://github.com/cloverstd

COPY aliyun.sources.list /etc/apt/sources.list
RUN set -ex && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git autoconf libtool automake wget && \
    mkdir /tmp/src && cd /tmp/src && \
    wget --no-check-certificate -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.3.0.zip && \
    unzip nginx-ct.zip && \
    git config --global http.sslVerify false && \
    git clone https://github.com/bagder/libbrotli && \
    cd libbrotli && \
    ./autogen.sh && ./configure && make && make install && cd ../ && \
    ln -s /usr/local/lib/libbrotlienc.so.1 /usr/lib/libbrotlienc.so.1 && \
    git clone https://github.com/google/ngx_brotli.git && \
    wget --no-check-certificate -O openssl.tar.gz -c https://www.openssl.org/source/openssl-1.1.0.tar.gz && \
    tar zxf openssl.tar.gz && \
    mv openssl-1.1.0/ openssl && \
    wget --no-check-certificate -c https://nginx.org/download/nginx-1.11.4.tar.gz && \
    tar zxf nginx-1.11.4.tar.gz && \
    cd nginx-1.11.4/ && \
    ./configure --add-module=../ngx_brotli --add-module=../nginx-ct-1.3.0 --with-openssl=../openssl --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module && \
    make  && make install && \
    rm -rf /tmp/src && apt-get remove -y unzip git autoconf libtool wget automake build-essential


# forward request and error logs to docker log collector
# from https://github.com/nginxinc/docker-nginx
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/nginx/logs/error.log

EXPOSE 80 443

#ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
