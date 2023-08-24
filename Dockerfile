FROM nginx:1.25.2

ARG UID=${UID:-1000}
ARG GID=${GID:-1000}

RUN usermod -u $UID www-data && groupmod -g $GID www-data

VOLUME /media

COPY webdav.conf /etc/nginx/conf.d/default.conf