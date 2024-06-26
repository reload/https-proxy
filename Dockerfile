FROM nginx:1.26.1-alpine3.19-slim@sha256:ce01dacf330fdcbc3c93926291ab027396e7e9680a4180318b06e86525d1aa9f

COPY context/ /

RUN apk add --no-cache \
    bash=~5 \
    ca-certificates=~20240226 \
    gnutls-utils=~3 \
    tini=~0

ARG workdir=/var/www
WORKDIR "${workdir}"

ENV NGINX_FASTCGI_PASS_HOST php
ENV NGINX_FASTCGI_PASS_PORT 9000
ENV NGINX_LISTEN 80
ENV PROFILE drupal

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/entrypoint" ]
CMD [ "nginx", "-g", "daemon off;" ]
