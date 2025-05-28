FROM ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest

COPY --from=composer:2   /usr/bin/composer /usr/bin/composer
COPY --from=node:16-slim /usr/local/bin /usr/local/bin
COPY --from=node:16-slim /usr/local/lib/node_modules /usr/local/lib/node_modules

SHELL ["/bin/bash", "--login", "-c"]

RUN \
  apt-get update && \
  apt-get -y install \
    git \
    unzip \
    vim \
    zip  \
  && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt


RUN npm install -g yarn --force

RUN \
  pecl install xdebug-3.1.6 && \
  docker-php-ext-enable xdebug
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN \
  rm -rf /etc/apache2/sites-enabled/* && \
  mkdir /var/www/html/public

COPY ./conf/appconf.conf /etc/apache2/sites-enabled/
