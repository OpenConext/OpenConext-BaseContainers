FROM debian:bullseye-20230227-slim

# Do an initial clean up and general upgrade of the distribution
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

# Install PHP 7.2, FPM and Apache2
RUN apt install -y php7.2 \
        php7.2-fpm \
        php7.2-soap \
        php7.2-gd \
        php7.2-mysql \
        php7.2-opcache \
        php7.2-xml \
        php7.2-mbstring \
        php7.2-apcu \
        php7.2-curl \
        apache2

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Add the PHP conf files
COPY conf/php.ini /etc/php/7.2/fpm/php.ini
COPY conf/www.conf /etc/php/7.2/fpm/pool.d/www.conf

# Add the startup script
COPY bin/start.sh /usr/local/bin/start.sh

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
