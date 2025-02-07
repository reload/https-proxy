# HTTPS proxy

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
> generate and install a root certificate on your host machine by
> running (one time only).
>
> ```console
> mkcert -install
> ```

### Mac users

> [!TIP]
>
> Mac users should do the following (one time only) while no
> containers are running:
>
> ```console
> mkdir -p ~/.local/share && find ~/.local/share -name mkcert -type d -delete && ln -s "$(mkcert -CAROOT)" ~/.local/share`
> ```
>
> If you haven't installed mkcert yet, you can do so with Homebrew:
>
> ```console
> brew install mkcert nss
> ```
>
> [Dory](https://github.com/FreedomBen/dory) users must adjust their
> config (run `dory config` or edit `~/.dory.yml`):
>
> ```yaml
> nginx_proxy:
>     enabled: true
>     container_name: dory_dinghy_http_proxy
>     https_enabled: true
>     # Update the follow line to point at the dev_certificates
>     ssl_certs_dir: /Users/<username>/.local/share/dev_certificates
>     image: codekitchen/dinghy-http-proxy:latest
> ```
>
> Remeber to restart Dory.

Use can use the following configuration for the generated certificate:

```yaml
environment:
  EXPIRATION_DAYS: 30
  VIRTUAL_HOST: example.local
```

## Predefined configurations

This nginx proxy comes with three predefined configurations:

- Proxy
- Vite
- Next.js
- Storybook
- Drupal

### Proxy

Proxy is a generic configuration that just forwards requests to the
backend.

```yaml
image: ghcr.io/reload/https-proxy:proxy
```

See the configuration details in
[`context/proxy/etc/nginx/templates/default.conf.template`](context/proxy/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_DOCUMENT_ROOT: /var/www/web
  NGINX_PROXY_PASS: <no default>
```

### Vite

Vite is like the proxy configuration but also forwards all WebSocket
requests.

```yaml
image: ghcr.io/reload/https-proxy:vite
```

See the configuration details in
[`context/vite/etc/nginx/templates/default.conf.template`](context/nextjs/etc/vite/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_DOCUMENT_ROOT: /var/www/web
  NGINX_PROXY_PASS: http://app:5173
```

### Next.js

Next.js is like the proxy configuration but also forwards WebSocket
connections on the path `/_next/webpack-hmr`.

```yaml
image: ghcr.io/reload/https-proxy:nextjs
```

See the configuration details in
[`context/nextjs/etc/nginx/templates/default.conf.template`](context/nextjs/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_DOCUMENT_ROOT: /var/www/web
  NGINX_PROXY_PASS: http://app:3000
```

### Storybook

Storybook is like the proxy configuration but also forwards WebSocket
connections on the paths `/__webpack-hmr` and
`/storybook-server-channel`.

```yaml
image: ghcr.io/reload/https-proxy:storybook
```

See the configuration details in
[`context/storybook/etc/nginx/templates/default.conf.template`](context/storybook/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_DOCUMENT_ROOT: /var/www/web
  NGINX_PROXY_PASS: http://app:6006
```

### Drupal

Drupal is a configuration that forwards PHP-FPM requests to a Drupal
development server. So strictly speaing this is not a proxy.

```yaml
image: ghcr.io/reload/https-proxy:drupal
```

See the configuration details in
[`context/drupal/etc/nginx/templates/default.conf.template`](context/drupal/etc/nginx/templates/default.conf.template).

Use can use the following configuration in your `docker-compose.yml`:

```yaml
environment:
  NGINX_DOCUMENT_ROOT: /var/www/web
  NGINX_FASTCGI_PASS_HOST: php
  NGINX_FASTCGI_PASS_PORT: 9000
  NGINX_CLIENT_MAX_BODY_SIZE: 128M
```

## Base image

There is also a base configuration that comes with no predefined
configuration.

```yaml
image: ghcr.io/reload/https-proxy:base
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
> current production hosting practice (nginx, again), should be easier
> to maintain and keep up-to-date, and also supports Next.js,
> Storybook, and generic proxies.
