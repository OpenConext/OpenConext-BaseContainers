FROM docker.io/library/php:7.2-apache-buster
#Some default environment variables. They can be overridden when starting the container
ENV PHP_MEMORY_LIMIT=128M
ENV TZ=Europe/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive
# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Install the packages we need
RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    libxml2 \
    libxml2-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgmp3-dev

# Install the PHP 7.2 extensions we need
RUN docker-php-ext-install -j$(nproc) soap
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) gmp

RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) gd

# Use pecl to install acpu
RUN pecl install -f apcu
RUN pecl install -f apcu_bc
COPY ./conf/apcu.ini /usr/local/etc/php/conf.d/91-apcu.ini
COPY ./conf/apc.ini  /usr/local/etc/php/conf.d/92-acp.ini

# Clean up
# don't autoremove, becasue that will remove libraries needed for the custom-built php extensions
RUN \
  apt-get -y purge \
    libxml2-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgmp-dev \
    libgmp3-dev \
    icu-devtools \
    zlib1g-dev \
  && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt

# Enable the Apache2 modules we need and disable the ones we don't need
RUN \
  a2enmod rewrite headers expires proxy_fcgi remoteip \
  && \
  a2dismod status

# Copy the openconext specific config
COPY ./conf/openconext.conf  ./conf/security.conf  /etc/apache2/conf-enabled/
COPY ./conf/php.ini ./conf/php-cli.ini /usr/local/etc/php/

# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
