FROM docker.io/library/php:8.2-apache-bullseye
#Some default environment variables. They can be overridden when starting the container
ENV PHP_MEMORY_LIMIT=128M
ENV TZ=Europe/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive

# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 --chmod=755 /usr/bin/composer /usr/bin/composer

# Install the packages we need
RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    libfreetype6-dev \
    libgmp3-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2 \
    libxml2-dev \
  && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt

# Install the PHP 8.2 extensions we need
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) opcache
RUN docker-php-ext-install -j$(nproc) gmp
RUN docker-php-ext-install -j$(nproc) xml

RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install -j$(nproc) gd

# install xdebug but do not enable by default
RUN pecl install xdebug

# Clean up
# don't autoremove, becasue that will remove libraries needed for the custom-built php extensions
RUN \
  apt-get -y purge \
    icu-devtools \
    libfreetype6-dev \
    libgmp-dev \
    libgmp3-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
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
COPY --chmod=755 ./bin/entrypoint.sh /entrypoint.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
