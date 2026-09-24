# OpenConext Base containers

We provide the following base containers which can be used in downstream projects:

## Apache2 containers

### Plain Apache

![Build status for plain apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2.yaml/badge.svg)

### Apache 2 with shibboleth

![Build status for apache2 shibboleth production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2-shibboleth.yaml/badge.svg)

## JAVA containers

**Plain JAVA 21**
![Build status for plain JAVA 21 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-java21.yaml/badge.svg)

**Rootless JAVA 21**
![Build status for rootless JAVA 21 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-java21-rootless.yaml/badge.svg)

The rootless image runs the JVM as an unprivileged user instead of root, and the container itself never needs to start as root either. An "openconext" user is created at build time and is the default user of the container. By default it has uid/gid 1001, this can be changed at build time with the USER_UID and USER_GID build args so it matches the uid/gid of your mounted files:

```sh
docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
```

For a one-off override without rebuilding, use `--user`:

```sh
docker run --user #1337:#1337 ghcr.io/openconext/openconext-basecontainers/java21-rootless:latest java -jar /app/app.jar
```

## PHP 72 images

**PROD image:**

![Build status for php72 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2.yaml/badge.svg)

**Dev images:**

![Build status for php72 apache2 node14 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2-node14-composer2.yaml/badge.svg)
![Build status for php72 apache2 node16 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2-node16-composer2.yaml/badge.svg)

## PHP 8.2 images

**PROD image:**

![Build status for php82 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2.yaml/badge.svg)

**Dev images:**

![Build status for php82 apache2 node20 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2-node20-composer2.yaml/badge.svg)

## Rootless variants

Rootless variants of the base containers run their service as an unprivileged "openconext" user instead of root, and the container itself never needs to start as root either (running one as root only produces a warning). An "openconext" user is created at build time with uid/gid 1001 by default. This can be changed at build time with the USER_UID and USER_GID build args so it matches the uid/gid of your mounted files:

```sh
docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
```

For a one-off override without rebuilding, use `--user`:

```sh
docker run --user #1337:#1337 ghcr.io/openconext/openconext-basecontainers/<image>-rootless:latest
```

### Differences from the regular images

- The service runs as the unprivileged `openconext` user (default uid/gid 1001) and the container never needs to start as root. If you do start it as root, the entrypoint prints a warning but allows it, e.g. for debugging.
- The apache based images listen on port **8080** instead of **80** (and the vhost is `*:8080`), because an unprivileged process cannot bind to port 80. All other ports must be >= 1024 as well.
- The runtime uid/gid environment variables of the regular images are **not** used: `APACHE_UID`/`APACHE_GID` (apache and php images) and `RUNAS_UID`/`RUNAS_GID` (python3 and satosa images) are ignored. The uid/gid are fixed at build time with the `USER_UID`/`USER_GID` build args, or per-run with `docker run --user #<uid>:#<gid>`.
- The regular images import `/config/haproxy/haproxy.crt` into the CA bundle at start, which requires root. In the rootless images add the certificate at build time instead (see below).
- The php images still run `bin/console cache:clear` at every start, but since they no longer chown the app directories at start, the app files must be writable by the `openconext` user (see below).

### Adapting a downstream image

The rootless base images set `USER openconext`, which affects both the build and the runtime of your image:

1. **Build steps need root again.** Steps that install packages (`apt-get`, `pecl`, `pip install`, `npm install -g`, ...) must run as root, so set `USER root` before them and restore `USER openconext` at the end. If you don't set `USER` at all, the unprivileged user of the base image is inherited and that's fine.
2. **Make writable files owned by the service user.** Files and directories the service writes to at runtime must be owned by (or writable by) `openconext`. Use `COPY --chown=openconext:openconext` for application code that contains writable dirs (e.g. the Symfony `var/cache` and `var/log` directories), and `chown` in a build step for anything else (logs, data, temp dirs).
3. **Listen on ports >= 1024.** Update `EXPOSE`, the app config and anything that assumes port 80 (vhosts, proxy configs, health checks).
4. **Certificates and other root-only setup at build time.** Anything the regular entrypoints did as root at start (importing the haproxy CA certificate, `update-ca-certificates`) has to be done in a `RUN` step instead, e.g.:

   ```dockerfile
   COPY ./config/haproxy.crt /usr/local/share/ca-certificates/haproxy.crt
   RUN update-ca-certificates
   ```
5. **Entrypoint/CMD.** If you override `ENTRYPOINT`, remember that doing so clears the `CMD` inherited from the base image, so set both. You can keep the base entrypoint (which warns when run as root) by only overriding `CMD`, e.g. `CMD ["java","-jar","/app/app.jar"]`.

Example for a Java application:

```dockerfile
FROM ghcr.io/openconext/openconext-basecontainers/java21-rootless:latest

# build steps need root
USER root
# ... apt-get / other installation ...

# the jar is in the workdir, owned by the service user
COPY --chown=openconext:openconext target/*.jar /app/app.jar

# back to the unprivileged user. Setting CMD keeps the base image's
# ENTRYPOINT (which warns when run as root) in the chain.
USER openconext
CMD ["java", "-jar", "/app/app.jar"]
```

Example for a Symfony / PHP application:

```dockerfile
FROM ghcr.io/openconext/openconext-basecontainers/php85-apache2-rootless:latest

# build steps need root
USER root
RUN apt-get update && apt-get -y install <packages> && rm -rf /var/lib/apt/lists/*

# the app writes to var/cache and var/log at runtime, so it must be
# owned by the service user
COPY --chown=openconext:openconext --chmod=755 ./var /var/www/html/var
COPY --chown=openconext:openconext ./ /var/www/html/

USER openconext
```

### Deploying rootless containers

- **Volume ownership.** Mounted volumes must be readable (and writable, where the service writes) by the `openconext` user. Either make the host files owned by uid/gid 1001, or rebuild the image with `--build-arg USER_UID=<uid> --build-arg USER_GID=<gid>` so the in-container user matches the existing host files.
- **Ports and routing.** The apache based images serve on 8080 instead of 80, so update `ports:`, `expose:`, proxy and loadbalancer configs, and application URLs that contain the port.
- **Kubernetes.** Containers now start as a non-root user automatically; if your PodSecurityContext enforces `runAsNonRoot`, these images satisfy it. Set `fsGroup` to the gid of the image (1001 by default) for writable volumes.
- **One-off uid/gid.** `docker run --user #<uid>:#<gid>` works without rebuilding. Note that the default workdir/app dirs are then owned by the image's build-time user, so pick a matching uid/gid if you need write access to them.

**Rootless Apache 2**
![Build status for rootless apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2-rootless.yaml/badge.svg)

**Rootless Apache 2 with shibboleth**
![Build status for rootless apache2 shibboleth production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2-shibboleth-rootless.yaml/badge.svg)

**Rootless HAProxy 2.8** (already non-root in the upstream image; this variant uses the same "openconext" user as the other rootless images. The container does not ship a config, downstream images must provide one that only binds ports >= 1024.)
![Build status for rootless haproxy28 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-haproxy28-rootless.yaml/badge.svg)

**Rootless PHP 8.2 Apache 2**
![Build status for rootless php82 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2-rootless.yaml/badge.svg)

**Rootless PHP 8.2 Apache 2 node20 composer2**
![Build status for rootless php82 apache2 node20 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2-node20-composer2-rootless.yaml/badge.svg)

**Rootless PHP 8.5 Apache 2**
![Build status for rootless php85 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php85-apache2-rootless.yaml/badge.svg)

**Rootless PHP 8.5 Apache 2 node24**
![Build status for rootless php85 apache2 node24 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php85-apache2-node24-rootless.yaml/badge.svg)

**Rootless Python 3** (the scripts in /container-init and /container-init-post are run as the unprivileged user; the RUNAS_UID / RUNAS_GID env vars of the non-rootless image are not used, the uid/gid are set at build time instead.)
![Build status for rootless python3 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-python3-rootless.yaml/badge.svg)

**Rootless SATOSA** (the RUNAS_UID / RUNAS_GID env vars of the non-rootless image are not used, the uid/gid are set at build time instead.)
![Build status for rootless satosa production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-satosa-rootless.yaml/badge.svg)

## Features

- At every start, the php containers will recreate the symfony cache dir.
- You can supply the environment variable APACHE_UID. It creates the user "openconext", and starts Apache with that the supplied uid.
  This allows for strict permissions on mounted files.
  You need to prefix the uid with a # like so:

```sh
docker run -e APACHE_UID=#1337 ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest
```

- At every start, the php containers will recreate the symfony cache dir. </br>
- You can supply the environment variables APACHE_UID and APACHE_GID. It creates the user and group "openconext", and starts Apache with the supplied uid and gid.

This allows for strict permissions on mounted files.
You need to prefix the uid/gid with a # like so:

```sh
docker run -e APACHE_UID=#1337 -e APACHE_GID=#1337 ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest
```

- You can supply the environment variable "HTTPD_CSP" which will set the CSP header on responses.
- You can supply the environment variable TZ to set the timezone on the php82 containers
- You can add PHP_MEMORY_LIMIT to override the default setting of 128M php memory limit on the php82 containers

### satosa container

- At every start, the satosa container will create a new satosa user and group.
- You can supply the environment variables RUNAS_UID and RUNAS_GID to configure the chosen uid and gid inside the container.
- Without RUNAS_UID and RUNAS_GID the container will fall back to uid=1000 and gid=1000

```sh
docker run -e RUNAS_UID=1234 -e RUNAS_GID=1234 --rm ghcr.io/openconext/openconext-basecontainers/satosa:latest
```
