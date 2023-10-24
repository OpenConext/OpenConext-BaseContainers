FROM httpd:2.4

# Do an initial clean up and general upgrade of the distribution
ENV DEBIAN_FRONTEND noninteractive
RUN apt clean && apt autoclean && apt update
RUN apt -y upgrade && apt -y dist-upgrade

# Install the packages we need
RUN apt install -y curl \
  procps

# Clean up
RUN apt autoremove -y && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

# Copy the default apache config
COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf

# Set the default workdir
WORKDIR /usr/local/apache2

# Default port to listen on
EXPOSE 80

# Start Apache
CMD ["httpd-foreground"]