# HTTPS proxy

> [!CAUTION]
> Work in progress!

A nginx proxy with HTTPS support for Docker Compose development
environments.

## HTTPS configuration

The proxy uses a self-signed certificate for HTTPS. You can use a root
certificate, e.g., one generated with mkcert to avoid browser
warnings.

Mount the root certificate like this

```yaml
volumes:
 - '${HOME}/.local/share/mkcert:/rootCA:ro'
 - '${HOME}/.local/share/dev_certificates:/cert:rw'
```

> [!TIP]
>
> Install [mkcert](https://mkcert.dev) on your host machine and
> generate and install a root certificate by running `mkcert -install`
> on your host machine (one time only).
>
> Mac users should then do (one time only):
>
> `$ mkdir -p ~/.local/share && ln -s "$(mkcert -CAROOT)" ~/.local/share`

Use can use the following configuration for the generated certificate:

```yaml
environment:
  EXPIRATION_DAYS: 30
  VIRTUAL_HOST: example.local
```

## Predefined configurations

This nginx proxy comes with three predefined configurations:

- Proxy
- Next.js
- Drupal

### Proxy

Proxy is a generic configuration that just forwards requests to the
backend.

```yaml
image: ghcr.io/arnested/https-proxy:proxy
```

See the configuration details in
[`context/proxy/etc/nginx/templates/default.conf.template`](context/proxy/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_PROXY_PASS: <no default>
```

### Next.js

Next.js is like the proxy configuration but also forwards WebSocket
connections on the path `/_next/webpack-hmr`.

```yaml
image: ghcr.io/arnested/https-proxy:nextjs
```

See the configuration details in
[`context/nextjs/etc/nginx/templates/default.conf.template`](context/nextjs/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_PROXY_PASS: app:3000
```

### Drupal

Drupal is a configuration that forwards requests to a Drupal
development server.

```yaml
image: ghcr.io/arnested/https-proxy:drupal
```

See the configuration details in
[`context/drupal/etc/nginx/templates/default.conf.template`](context/drupal/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_FASTCGI_PASS_HOST: php
  NGINX_FASTCGI_PASS_PORT: 9000
  NGINX_CLIENT_MAX_BODY_SIZE: 128M
```

## Base image

There is also a base configuration that comes with no predefined
configuration.

```yaml
image: ghcr.io/arnested/https-proxy:base
```

You can add your own configuration by mounting a volume to
`/etc/nginx/templates` or `/etc/nginx/conf.d`.

You can include the predefined SSL configurations by adding the
following:

```nginx
include include.d/ssl.conf;
```

> [!NOTE]
>
> This image is meant to replace
> [drupal-apache-fpm](https://github.com/reload/drupal-apache-fpm),
> which we have used for most of our projects.
>
> The new approach is smaller (due to using nginx), more inline with
> current production hosting practice (nginx, again), also supports
> Next.js, and should be easier to maintain and keep up-to-date.
