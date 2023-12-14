FROM ghcr.io/openconext/openconext-basecontainers/apache2:latest

# Set things up for Apt
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update

# Install the Shibboleth daemon and Apache2 modules
RUN apt install -y shibboleth-sp-common \
  shibboleth-sp-utils \
  libapache2-mod-shib \
  gettext

# Clean up
RUN apt autoremove -y && \ 
  apt clean && \ 
  apt autoclean && \
  rm -rf /var/lib/apt/lists/* && \
  a2enmod shib && \
  mkdir -p /run/shibboleth

# Copy config files
COPY ./conf/shibboleth/* /etc/shibboleth/

# Copy the startup script
COPY ./bin/entrypoint.sh /entrypoint.sh
COPY ./bin/shib.sh /usr/local/bin/shib.sh
RUN chmod +x /entrypoint.sh ; chmod +x /usr/local/bin/shib.sh

# Copy the entrypoint script
COPY ./bin/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Shibboleth and Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD["/usr/local/bin/shib.sh"]

