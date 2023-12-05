FROM debian:bookworm-slim

# Update and install packages needed 
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
  apt -y upgrade && \
  apt -y install -y apache2 \
  curl

# Clean up
RUN apt autoremove -y && \
  apt clean && \
  apt autoclean && \
  rm -rf /var/lib/apt/lists/*

# Enable the apache2 modules we need
RUN a2enmod authz_groupfile \
  xml2enc \
  headers \
  ssl \
  proxy \
  proxy_connect \
  proxy_http \
  rewrite

# Copy the default apache config
COPY ./conf/apache2.conf /etc/apache2/apache2.conf
COPY ./conf/security.conf /etc/apache2/conf-available/security.conf
COPY ./conf/default-vhost.conf /etc/apache2/sites-available/000-default.conf

# Copy the startup script
COPY ./bin/start.sh /usr/local/bin/start.sh

# Create the Apache2 run dir
RUN mkdir -p /var/run/apache2

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 80

# Start Apache
ENTRYPOINT ["/usr/local/bin/start.sh"]
