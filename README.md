# OpenConext Base containers

We provide the following base containers which can be used in downstream projects:

## Apache2 containers
**Plain Apache**</br>
![Build status for plain apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2.yaml/badge.svg)

**Apache 2 with shibboleth**</br>
![Build status for apache2 shibboleth production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-apache2-shibboleth.yaml/badge.svg)


## PHP 72 images

**PROD image:**</br>
![Build status for php72 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2.yaml/badge.svg)

**Dev images:**</br>
![Build status for php72 apache2 node14 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2-node14-composer2.yaml/badge.svg)</br>
![Build status for php72 apache2 node16 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php72-apache2-node16-composer2.yaml/badge.svg)


## PHP 8.2 images

**PROD image:**<br>

![Build status for php82 apache2 production image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2.yaml/badge.svg)

**Dev images:** </br>
![Build status for php82 apache2 node16 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2-node16-composer2.yaml/badge.svg)<br>
![Build status for php82 apache2 node20 image](https://github.com/OpenConext/OpenConext-BaseContainers/actions/workflows/build-php82-apache2-node20-composer2.yaml/badge.svg)

## Features

- At every start, the php containers will recreate the symfony cache dir. </br>
- You can supply the environment variable APACHE_UID. It creates the user "openconext", and starts Apache with that the supplied uid. 
This allows for strict permissions on mounted files.
You need to prefix the uid with a # like so:
```
docker run -e APACHE_UID=#1337 ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest
```
- You can supply the environment variable "HTTPD_CSP" which will set the CSP header on responses.
- You can supply the environment variable TZ to set the timezone on the php82 containers
- You can add PHP_MEMORY_LIMIT to override the default setting of 128M php memory limit on the php82 containers



