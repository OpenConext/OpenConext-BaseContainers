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
