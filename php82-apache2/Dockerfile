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
  gd

# Clean up
RUN apt remove -y autoconf \
    gcc g++ make \
    dpkg-dev icu-devtools \
    libc-dev-bin \
    libxml2-dev:arm64 \
    linux-libc-dev:arm64 \
    libicu-dev:arm64 \
    libgmp-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    curl && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
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
