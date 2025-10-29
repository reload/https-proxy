##
#  Base
##
FROM nginx:1.29.3-alpine-slim@sha256:7fef55f3148d8ddf39cafa44f1fb879a95bf106d27b093e8d6d088c1a0f57243 AS base

COPY /base /

RUN apk add --no-cache \
    ca-certificates=~20250911 \
    gnutls-utils=~3

ARG workdir=/var/www
WORKDIR "${workdir}"

HEALTHCHECK --interval=10s --start-period=90s CMD netstat -ltn | grep -c ":443"

ENV EXPIRATION_DAYS=30
ENV NGINX_DOCUMENT_ROOT=/var/www/web

##
#  Drupal
##
FROM base AS drupal

COPY /drupal /

ENV NGINX_FASTCGI_PASS_HOST=php
ENV NGINX_FASTCGI_PASS_PORT=9000
ENV NGINX_CLIENT_MAX_BODY_SIZE=128M

##
#  Proxy
##
FROM base AS proxy

COPY /proxy /

##
#  Vite
##
FROM proxy AS vite

COPY /vite /

ENV NGINX_PROXY_PASS=http://app:5173

##
#  NextJS
##
FROM proxy AS nextjs

COPY /nextjs /

ENV NGINX_PROXY_PASS=http://app:3000

##
#  Storybook
##
FROM proxy AS storybook

COPY /storybook /

ENV NGINX_PROXY_PASS=http://app:6006
