FROM docker.io/library/php:7.2-apache-buster
#Some default environment variables. They can be overridden when starting the container
ENV PHP_MEMORY_LIMIT=128M
ENV TZ=Europe/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive
# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Do an initial clean up and general upgrade of the distribution
#RUN apt clean && apt autoclean && apt update
#RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    libxml2 \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgmp3-dev

# Install the PHP 7.2 extensions we need
RUN docker-php-ext-install soap
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install opcache
RUN docker-php-ext-install gmp

RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) gd

# Use pecl to install acpu
RUN pecl install -f apcu
RUN pecl install -f apcu_bc
COPY ./conf/apcu.ini /usr/local/etc/php/conf.d/91-apcu.ini
COPY ./conf/apc.ini  /usr/local/etc/php/conf.d/92-acp.ini

# Enable the Apache2 modules we need
RUN a2enmod rewrite headers expires proxy_fcgi remoteip && \
    a2dismod status

# Copy the openconext specific config
COPY ./conf/openconext.conf  ./conf/security.conf  /etc/apache2/conf-enabled/
COPY ./conf/php.ini ./conf/php-cli.ini /usr/local/etc/php/

# Clean up
# don't autoremove, becasue that will remove libraries needed for the custom-built php extensions
# clean up
RUN apt-get -y purge \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgmp3-dev \
    icu-devtools \
    libicu-dev \
    libgmp-dev \
    zlib1g-dev \
    && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt

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
