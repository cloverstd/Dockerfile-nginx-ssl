VERSION = 0.1
NAME = nginx-ssl

LOG_DIR = $(shell pwd)/logs
NGINX_CONF_FILE = $(shell pwd)/nginx.conf
NGINC_CONF_D_DIR = $(shell pwd)/conf.d
SSL_DIR = $(shell pwd)/ssl
HTML_DIR = $(shell pwd)/html

all: prepare build clean

prepare:
	git clone https://github.com/cloudflare/sslconfig
	wget -O openssl.zip -c https://github.com/openssl/openssl/archive/OpenSSL_1_0_2h.zip
	unzip openssl.zip
	mv openssl-OpenSSL_1_0_2h/ openssl
	cd openssl && patch -p1 < ../sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102g.patch
	wget -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.2.0.zip
	unzip nginx-ct.zip
	wget -c https://nginx.org/download/nginx-1.9.7.tar.gz
	# prepare nginx
	tar zxf nginx-1.9.7.tar.gz
	cd nginx-1.9.7 && patch -p1 < ../sslconfig/patches/nginx__http2_spdy.patch
	cd nginx-1.9.7 && patch -p1 < ../sslconfig/patches/nginx__dynamic_tls_records.patch

build:
	# build image
	docker build -t $(NAME):$(VERSION) .

clean:
	@echo "clean start"
	@rm -rf sslconfig \
		openssl.zip \
		openssl \
		nginx-ct.zip \
		nginx-1.9.7.tar.gz \
		nginx-1.9.7 \
		nginx-ct*
	@echo "clean done"

run:
	@docker run -d \
		-p 80:80 \
		-p 443:443 \
		--name nginx-ssl \
		-v $(LOG_DIR):/usr/local/nginx/logs \
		-v $(NGINX_CONF_FILE):/usr/local/nginx/conf/nginx.conf \
		-v $(NGINC_CONF_D_DIR):/usr/local/nginx/conf/conf.d:ro \
		-v $(SSL_DIR):/ssl:ro \
		-v $(HTML_DIR):/html \
		$(NAME):$(VERSION)
