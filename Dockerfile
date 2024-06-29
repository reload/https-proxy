##
#  Base
##
FROM nginx:1.27.0-alpine3.19-slim@sha256:66943ac4a1ca7f111097d3c656939dfe8ae2bc8314bb45d6d80419c5fb25e304 AS base

COPY /base /

RUN apk add --no-cache \
    ca-certificates=~20240226 \
    gnutls-utils=~3

ARG workdir=/var/www
WORKDIR "${workdir}"

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

ENV NGINX_PROXY_PASS app:3000
