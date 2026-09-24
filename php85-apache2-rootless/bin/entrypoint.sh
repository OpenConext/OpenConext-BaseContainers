#!/bin/sh
set -e

# This image is intended to run without root. The unprivileged user
# was created at build time (see USER_UID / USER_GID build args), so
# there is nothing to set up at start. Warn (but allow) if it is
# overridden to run as root anyway, e.g. for debugging.
if [ "$(id -u)" = "0" ]; then
    echo "WARNING: this image is intended to run without root." >&2
    echo "          You are running as root (e.g. via --user root)." >&2
fi

# Clear the PHP cache
if [ -f "/var/www/html/bin/console" ]; then
    php /var/www/html/bin/console cache:clear -e "${APP_ENV:-prod}"
fi

# Make sure the log directories exist
if [ -d "/var/www/html/var/cache" ]; then
    mkdir -p /var/www/html/var/log/
fi
if [ -d "/var/www/html/app/cache" ]; then
    mkdir -p /var/www/html/app/logs/
fi

# If we do not define the HTTPD_CSP env var, let's set an empty one so
# Apache stops complaining in the logs
if [ -z "${HTTPD_CSP:-}" ]; then
    export HTTPD_CSP=''
fi

# Note: the non-rootless image copies /config/haproxy/haproxy.crt into
# the CA bundle at start. That requires root, so in this image add the
# certificate at build time instead.

# Hand off to CMD
exec "$@"