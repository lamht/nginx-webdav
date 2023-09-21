FROM yobasystems/alpine:3.18.2-aarch64

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Dominic Taylor <dominic@yoba.systems>" \
    architecture="arm64v8/aarch64" \
    nginx-version="1.25.1" \
    alpine-version="3.18.2" \
    build="12-Jul-2023" \
    org.opencontainers.image.title="alpine-nginx" \
    org.opencontainers.image.description="Nginx container image running on Alpine Linux" \
    org.opencontainers.image.authors="Dominic Taylor <dominic@yoba.systems>" \
    org.opencontainers.image.vendor="Yoba Systems" \
    org.opencontainers.image.version="v1.25.1" \
    org.opencontainers.image.url="https://hub.docker.com/r/yobasystems/alpine-nginx/" \
    org.opencontainers.image.source="https://github.com/yobasystems/alpine-nginx" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE

ENV NGINX_VERSION=1.25.2
ENV NGINX_DAV_EXT_VER 3.0.0
ENV NGINX_FANCYINDEX_VER 0.5.2
ENV HEADERS_MORE_VER 0.34
ENV UID 1000
ENV GID 1000

RUN \
  build_pkgs="build-base linux-headers openssl-dev pcre-dev wget zlib-dev libxml2-dev libxslt-dev" && \
  runtime_pkgs="ca-certificates openssl pcre zlib tzdata git libxml2" && \
  apk --no-cache add ${build_pkgs} && \
  cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  wget https://github.com/arut/nginx-dav-ext-module/archive/v${NGINX_DAV_EXT_VER}.tar.gz \
    -O /tmp/nginx-dav-ext-module-v${NGINX_DAV_EXT_VER}.tar.gz && \
  wget https://github.com/aperezdc/ngx-fancyindex/archive/v${NGINX_FANCYINDEX_VER}.tar.gz \
    -O /tmp/ngx-fancyindex-v${NGINX_FANCYINDEX_VER}.tar.gz && \
  wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VER}.tar.gz \
    -O /tmp/headers-more-nginx-module-v${HEADERS_MORE_VER}.tar.gz && \
  tar xzf nginx-${NGINX_VERSION}.tar.gz && \
  tar xzf nginx-dav-ext-module-v${NGINX_DAV_EXT_VER}.tar.gz && \
  tar xzf ngx-fancyindex-v${NGINX_FANCYINDEX_VER}.tar.gz && \
  tar xzf headers-more-nginx-module-v${HEADERS_MORE_VER}.tar.gz && \
  cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-http_v2_module \
    --add-module=/tmp/nginx-dav-ext-module-${NGINX_DAV_EXT_VER} \
    --add-module=/tmp/ngx-fancyindex-${NGINX_FANCYINDEX_VER} \
    --add-module=/tmp/headers-more-nginx-module-${HEADERS_MORE_VER} && \
  make && \
  make install && \
  sed -i -e 's/#access_log  logs\/access.log  main;/access_log \/dev\/stdout;/' -e 's/#error_log  logs\/error.log  notice;/error_log stderr notice;/' /etc/nginx/nginx.conf && \
  addgroup -S -g ${GID} nginx && \
  adduser -D -S -u ${UID} -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
  rm -rf /tmp/* && \
  apk del ${build_pkgs} && \
  apk --no-cache add ${runtime_pkgs} && \
  rm -rf /var/cache/apk/*

RUN mkdir /data \
  && chown -R nginx:nginx /data

VOLUME /data

COPY nginx.conf /etc/nginx/
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

EXPOSE 80 443

CMD sh /entrypoint.sh && nginx