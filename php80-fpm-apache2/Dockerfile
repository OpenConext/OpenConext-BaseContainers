FROM debian:bullseye-20230227-slim

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y software-properties-common \
        ca-certificates \
        lsb-release \
        apt-transport-https \
        curl \
        wget \
        gnupg

# Add the sury.org dpkg repository for the PHP packages
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    apt update

# Install PHP 8.0, FPM and Apache2
RUN apt install -y php8.0 \
        php8.0-fpm \
        php8.0-soap \
        php8.0-gd \
        php8.0-mysql \
        php8.0-opcache \
        php8.0-xml \
        php8.0-mbstring \
        php8.0-apcu \
        php8.0-curl \
        apache2

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Add the PHP conf files
COPY conf/php.ini /etc/php/8.0/fpm/php.ini
COPY conf/www.conf /etc/php/8.0/fpm/pool.d/www.conf

# Add the startup script
COPY bin/start.sh /usr/local/bin/start.sh

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
