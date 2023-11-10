FROM ghcr.io/openconext/openconext-basecontainers/apache2:latest

# Set things up for Apt
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update

# Install the Shibboleth daemon and Apache2 modules
RUN apt install -y shibboleth-sp-common \
    shibboleth-sp-utils \
    libapache2-mod-shib

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Enable Shibboleth Apache2 module
RUN a2enmod shib

# Create the PIR directory for Shibboleth
RUN mkdir -p /run/shibboleth

# Copy config files
COPY ./conf/shibd.logger /etc/shibboleth/shibd.logger

# Copy the startup script
COPY ./bin/start.sh /usr/local/bin/start.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Shibboleth and Apache
CMD ["/usr/local/bin/start.sh"]
