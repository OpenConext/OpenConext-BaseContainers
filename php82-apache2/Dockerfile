FROM php:8.2.6-apache-bullseye

# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y curl \
  libgmp-dev \
  libicu-dev

# Install the PHP extensions we need
RUN docker-php-ext-install gmp \
  opcache  \
  intl

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

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
