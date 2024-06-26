FROM nginx:1.27.0-alpine3.19-slim@sha256:66943ac4a1ca7f111097d3c656939dfe8ae2bc8314bb45d6d80419c5fb25e304

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
