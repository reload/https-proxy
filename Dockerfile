##
#  Base
##
FROM nginx:1.27.0-alpine3.19-slim@sha256:128b00fcaa7b65716658bc2316a089ea9fc9b6ef8129b1db6d3643797e85dfca AS base

COPY /base /

RUN apk add --no-cache \
    ca-certificates=~20240226 \
    gnutls-utils=~3

ARG workdir=/var/www
WORKDIR "${workdir}"

HEALTHCHECK --interval=10s --start-period=90s CMD netstat -ltn | grep -c ":443"

ENV EXPIRATION_DAYS 30

##
#  Drupal
##
FROM base AS drupal

COPY /drupal /

ENV NGINX_FASTCGI_PASS_HOST php
ENV NGINX_FASTCGI_PASS_PORT 9000
ENV NGINX_CLIENT_MAX_BODY_SIZE 128M

##
#  Proxy
##
FROM base AS proxy

COPY /proxy /

##
#  NextJS
##
FROM proxy AS nextjs

COPY /nextjs /

ENV NGINX_PROXY_PASS http://app:3000
