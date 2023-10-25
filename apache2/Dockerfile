FROM debian:buster-slim

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y apache2 \
    curl

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Enable the apache2 modules we need
RUN a2enmod authz_groupfile \
    xml2enc \
    headers \
    proxy \
    proxy_connect \
    proxy_http \
    rewrite

# Copy the default apache config
COPY ./conf/apache2/apache2.conf /etc/apache2/apache2.conf
COPY ./conf/apache2/security.conf /etc/apache2/security.conf

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Apache
CMD ["apache2", "-D", "foreground"]
