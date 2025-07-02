FROM ghcr.io/openconext/openconext-basecontainers/apache2:latest

# Install the Shibboleth daemon and Apache2 modules
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt update && \
    apt install -y \
        shibboleth-sp-common \
        shibboleth-sp-utils \
        libapache2-mod-shib \
        gettext \
    && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*


# Enable Shib
RUN mkdir -p /run/shibboleth
RUN a2enmod shib

# Copy config files
COPY ./conf/shibboleth/* /etc/shibboleth/

# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
COPY ./bin/shib.sh /usr/local/bin/shib.sh
RUN chmod +x /entrypoint.sh ; chmod +x /usr/local/bin/shib.sh

# Copy the entrypoint script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Shibboleth and Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/shib.sh"]
