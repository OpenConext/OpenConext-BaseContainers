FROM ghcr.io/openconext/openconext-basecontainers/apache2-rootless:latest

# The base image runs as the unprivileged user; build steps need root
USER root

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
    rm -rf /var/lib/apt/lists/* /var/cache/apt /var/log/alternatives.log /var/log/apt /var/log/dpkg.log

# Enable Shib and make sure the config, socket/pid, session and log
# directories are usable by the unprivileged user (both apache and
# shibd run as that user, and the entrypoint rewrites the shibboleth2.xml
# config at start)
RUN mkdir -p /run/shibboleth /var/lib/shibboleth /var/log/shibboleth \
 && chown -R openconext:openconext /run/shibboleth /etc/shibboleth /var/lib/shibboleth /var/log/shibboleth
RUN a2enmod shib

# Copy config files
COPY ./conf/shibboleth/* /etc/shibboleth/

# Copy the startup script
COPY --chmod=755 ./bin/entrypoint.sh /entrypoint.sh
COPY --chmod=755 ./bin/shib.sh /usr/local/bin/shib.sh

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 8080

# Start Shibboleth and Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/shib.sh"]

# Back to the unprivileged user
USER openconext