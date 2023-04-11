FROM php:7.2-fpm-buster

# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer:1.9.3 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y curl \
        apache2 \
        libxml2 \
        libxml2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev

# Install the PHP 7.2 extensions we need
RUN docker-php-ext-install soap \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        opcache \
        xml \
        mbstring

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Enable the Apache2 modules we need
RUN a2enmod rewrite headers expires proxy_fcgi

# Add the PHP conf files
COPY conf/php.ini /etc/php/7.2/fpm/php.ini
COPY conf/www.conf /etc/php/7.2/fpm/pool.d/www.conf

# Add the startup script
COPY bin/start.sh /usr/local/bin/start.sh

# Default port to listen on
EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
