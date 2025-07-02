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
COPY --chmod=755 ./bin/entrypoint.sh /entrypoint.sh
COPY --chmod=755 ./bin/shib.sh /usr/local/bin/shib.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Shibboleth and Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/shib.sh"]
