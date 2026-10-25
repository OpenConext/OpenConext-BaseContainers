FROM docker.io/library/php:8.5-apache-trixie
#Some default environment variables. They can be overridden when starting the container
ENV PHP_MEMORY_LIMIT=128M
ENV TZ=Europe/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

# Copy the Composer PHAR from the Composer image into the PHP image
COPY --from=docker.io/library/composer:2 --chmod=755 /usr/bin/composer /usr/bin/composer

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
    rm -rf /var/lib/apt/lists/* /var/cache/apt /var/log/alternatives.log /var/log/apt /var/log/dpkg.log

# Install the PHP 8.5 extensions we need
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) gmp
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) bcmath

RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install -j$(nproc) gd

# install xdebug but do not enable by default
RUN \
    pecl install xdebug \
    && \
    rm -rf /tmp/pear


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
    rm -rf /var/lib/apt/lists/* /var/cache/apt  /var/log/alternatives.log /var/log/apt /var/log/dpkg.log

# Create the unprivileged user Apache2 will run as
RUN groupadd -g "${USER_GID}" openconext \
 && useradd -M -u "${USER_UID}" -g openconext -s /usr/sbin/nologin openconext

# Run Apache2 as the unprivileged user on an unprivileged port
RUN sed -i \
        -e 's/: \${APACHE_RUN_USER:=www-data}/: \${APACHE_RUN_USER:=openconext}/' \
        -e 's/: \${APACHE_RUN_GROUP:=www-data}/: \${APACHE_RUN_GROUP:=openconext}/' \
        /etc/apache2/envvars \
 && grep -q 'APACHE_RUN_USER:=openconext' /etc/apache2/envvars \
 && grep -q 'APACHE_RUN_GROUP:=openconext' /etc/apache2/envvars \
 && printf 'Listen 8080\n' > /etc/apache2/ports.conf \
 && mkdir -p /var/run/apache2 \
 && chown -R openconext:openconext /run /var/log/apache2 /var/www/html

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
EXPOSE 8080

# Run as the unprivileged user
USER openconext

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]