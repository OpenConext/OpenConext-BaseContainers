FROM docker.io/library/php:8.2-apache-bullseye
# Set the default workdir
WORKDIR /var/www/html
#Some default environment variables. They can be overridden when starting the container
ENV PHP_MEMORY_LIMIT=128M
ENV TZ=Europe/Amsterdam

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND=noninteractive

RUN apt clean && apt autoclean && apt update && apt -y upgrade

# Install the packages we need
# do some compiler magic, because some packages fail to compile with gcc, others fail with clang
RUN \
  apt install -y \
    clang-16 \
    curl \
    libpng16-16 \
    libjpeg62-turbo \
    libfreetype6 \
    libgmp-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev && \
  docker-php-ext-configure \
    gd --with-freetype --with-jpeg && \
  docker-php-ext-install -j$(nproc) \
    gmp \
    pdo_mysql \
    gd \
    intl \
    && \
  # opcache is a special case, it needs to be compiled with clang (or gcc will segfault)
  env CC=clang-16 docker-php-ext-install -j$(nproc) opcache  \
  apt -y remove \
    clang-16 \
    libgmp-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev && \
  apt autoremove --purge -y && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt

# Enable the Apache2 modules we need and disable the ones we don't need
RUN a2enmod rewrite headers expires proxy_fcgi remoteip && \
    a2dismod status
# Copy the openconext specific config
COPY ./conf/openconext.conf  ./conf/security.conf  /etc/apache2/conf-enabled/
COPY ./conf/php.ini ./conf/php-cli.ini /usr/local/etc/php/
# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
