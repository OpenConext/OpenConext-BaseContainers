FROM docker.io/library/debian:bookworm-slim

# Update and install packages needed
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt -y upgrade && \
    apt -y install \
        apache2 \
        curl \
        xz-utils  \
    && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

# Copy the default apache config
COPY ./conf/security.conf ./conf/openconext.conf /etc/apache2/conf-available/
COPY ./conf/default-vhost.conf /etc/apache2/sites-available/000-default.conf

# Enable the apache2 modules we need and disable the one we don't want.
RUN a2dismod  \
        status && \
    a2enmod \
        authz_groupfile \
        headers \
        proxy \
        proxy_connect \
        proxy_http \
        rewrite \
        remoteip \
        ssl \
        xml2enc && \
    a2enconf openconext

# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/run/apache2 && \
    rm -f /var/www/html/index.html

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]
