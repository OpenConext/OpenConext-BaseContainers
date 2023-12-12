FROM ghcr.io/openconext/openconext-basecontainers/php82-apache2:latest
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=node:20-slim /usr/local/bin /usr/local/bin
COPY --from=node:20-slim /opt /opt
COPY --from=node:20-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN apt update && apt -y install git unzip zip
RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/www/html/public
RUN rm -rf /etc/apache2/sites-enabled/*
COPY ./conf/appconf.conf /etc/apache2/sites-enabled/
