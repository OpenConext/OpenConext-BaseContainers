#!/usr/bin/env bash

# Check and read the user and group env vars set by the user
# Save them for later use as they will be overwritten by the next command
if [[ -v APACHE_RUN_USER ]]; then
    APACHE_UID=$APACHE_RUN_USER
fi
if [[ -v APACHE_RUN_GROUP ]]; then
    APACHE_GUID=$APACHE_RUN_GROUP
fi

# Read the envars for Apache2
source /etc/apache2/envvars

# Run as an arbitrary user / group if the user asked for one. It needs
# to be created first and stripped of the leading #
if [[ -v APACHE_UID ]]; then
    export APACHE_RUN_USER=$APACHE_UID
    APACHE_UID_TO_CREATE=$(echo $APACHE_UID | sed 's/#//')
        if [[ -v APACHE_GUID ]]; then
            export APACHE_RUN_GROUP=$APACHE_GUID
            APACHE_GUID_TO_CREATE=$(echo $APACHE_GUID | sed 's/#//')
            [ $(getent group openconext) ] || groupadd -g $APACHE_GUID_TO_CREATE openconext
            [ $(getent passwd openconext) ] || useradd -M -u $APACHE_UID_TO_CREATE -g $APACHE_GUID_TO_CREATE openconext
        else
            [ $(getent passwd openconext) ] || useradd -M -u $APACHE_UID_TO_CREATE openconext
    fi
fi

# Clear the PHP cache
if [[ -f "/var/www/html/bin/console" ]]; then
    exec php /var/www/html/bin/console cache:clear
fi

# Make sure the directories Apache2 needs are owned by the user running the daemon
for dir in \
    "$APACHE_RUN_DIR" \
    "$APACHE_LOG_DIR" \
    "/var/www/html" \
; do \
    if [[ -v APACHE_UID_TO_CREATE ]]; then
        if [[ -v APACHE_GUID_TO_CREATE ]]; then
            chown -R "$APACHE_UID_TO_CREATE:$APACHE_GUID_TO_CREATE" "$dir";
        else
            chown -R "$APACHE_UID_TO_CREATE" "$dir";
        fi
    else
        chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir";
    fi
    chmod 1777 "$dir";
done

# If we do not define the HTTPD_CSP env var, let's set an empty one so
# Apache stops complaining in the logs
if [[ ! -v HTTPD_CSP ]]; then
    export HTTPD_CSP=''
fi

# Copy and import the haproxy certificate if it exists
if [ -e /config/haproxy/haproxy.crt ]; then
    cp /config/haproxy/haproxy.crt /usr/local/share/ca-certificates/
    update-ca-certificates
fi

# Hand off to CMD
exec "$@"
