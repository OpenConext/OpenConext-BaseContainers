FROM ghcr.io/openconext/openconext-basecontainers/php72-apache2:latest
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=node:16-slim /usr/local/bin /usr/local/bin
COPY --from=node:16-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
SHELL ["/bin/bash", "--login", "-c"]
RUN apt update && apt -y install git unzip
RUN npm install -g yarn
RUN pecl install xdebug-2.9.0 && docker-php-ext-enable xdebug
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini