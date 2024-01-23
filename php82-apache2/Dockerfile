FROM php:8.2-apache-bullseye

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update

# Install the packages we need
RUN apt install -y curl \
  libpng16-16 \
  libjpeg62-turbo \
  libfreetype6 \
  libgmp-dev \
  libicu-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev &&\
  docker-php-ext-configure gd --with-freetype --with-jpeg &&\
  docker-php-ext-install -j$(nproc) gmp \
  opcache  \
  intl \
  pdo_mysql \
  gd

# Clean up
RUN apt -y remove libgmp-dev \
  libicu-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev && \
  apt autoremove -y && \
  apt clean && \
  apt autoclean && \
  rm -rf /var/lib/apt/lists/*

# Enable the Apache2 modules we need
RUN a2enmod rewrite headers expires proxy_fcgi remoteip
# Copy the openconext specific config 
COPY ./conf/openconext.conf  ./conf/security.conf  /etc/apache2/conf-enabled/
# Set the default workdir
WORKDIR /var/www/html

# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
