FROM php:7.2-apache-buster

# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y curl \
  libxml2 \
  libxml2-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libgmp3-dev

# Install the PHP 7.2 extensions we need
RUN docker-php-ext-install soap \
  gd \
  mysqli \
  pdo_mysql \
  opcache \
  intl \
  gmp

# Use pecl to install acpu
RUN pecl install -f apcu && \
  pecl install -f apcu_bc

COPY ./conf/apcu.ini /usr/local/etc/php/conf.d/000-docker-php-apcu.ini
COPY ./conf/apc.ini /usr/local/etc/php/conf.d/docker-php-apc.ini

# Clean up
RUN apt-get -y remove autoconf \
    gcc gcc-8 g++ g++-8 make \
    dpkg-dev icu-devtools \
    libc-dev-bin libxml2-dev:arm64 \
    linux-libc-dev:arm64 \
    libicu-dev:arm64 \
    libgcc-8-dev:arm64 \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev libgmp3-dev \
    curl && \
    apt autoremove -y && \
    apt clean && apt autoclean && \
    rm -rf /var/lib/apt/lists/*

# Enable the Apache2 modules we need
RUN a2enmod rewrite headers expires proxy_fcgi

COPY ./conf/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
