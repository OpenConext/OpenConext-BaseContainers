FROM docker.io/library/debian:bookworm-slim

# The unprivileged user is created at build time, so the container's
# first process never needs to run as root.
# Override at build time to match the uid/gid of your mounted files:
#   docker build --build-arg USER_UID=1337 --build-arg USER_GID=1337 .
ARG USER_UID=1001
ARG USER_GID=1001

# Update and install packages needed
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt -y upgrade && \
    apt -y install \
        apache2 \
        curl \
        xz-utils  \
    && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt /var/log/alternatives.log /var/log/apt /var/log/dpkg.log

# Create the unprivileged user Apache2 will run as
RUN groupadd -g "${USER_GID}" openconext \
 && useradd -M -u "${USER_UID}" -g openconext -s /usr/sbin/nologin openconext

# Run Apache2 as the unprivileged user on an unprivileged port
RUN sed -i \
        -e 's/^export APACHE_RUN_USER=.*/export APACHE_RUN_USER=openconext/' \
        -e 's/^export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=openconext/' \
        /etc/apache2/envvars \
 && printf 'Listen 8080\n' > /etc/apache2/ports.conf \
 && mkdir -p /var/run/apache2 \
 && chown -R openconext:openconext /run /var/log/apache2 /var/www/html

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
    rm -f /var/www/html/index.html

# Set the default workdir
WORKDIR /var/www/html

# Default port to listen on
EXPOSE 8080

# Run as the unprivileged user
USER openconext

# Start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]