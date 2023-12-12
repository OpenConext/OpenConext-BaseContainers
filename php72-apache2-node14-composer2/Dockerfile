FROM ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
SHELL ["/bin/bash", "--login", "-c"]
RUN apt update && apt -y install git unzip zip
COPY --from=node:14-slim /usr/local/bin /usr/local/bin
COPY --from=node:14-slim /opt /opt
COPY --from=node:14-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN npm install -g yarn --force
RUN pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN rm -rf /etc/apache2/sites-enabled/*
COPY ./conf/appconf.conf /etc/apache2/sites-enabled/
