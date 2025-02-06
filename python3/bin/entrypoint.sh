#!/usr/bin/env bash
set -e

# handle privilege dropping
if [ $UID -ne 0 ]
then
    echo "This container need to run as root"
    echo "Use USER/GROUP environment variables to specify the uid/gid to run as"

    exit 1
fi

# run custom scripts before dropping privileges
echo "Running custom scripts in /container-init"
if [ -d "/container-init" ]
then
    # run all scripts using run-parts
    run-parts --verbose "/container-init"
fi

# set up privilege dropping to user and group
PRIVDROP=
if [ -n "$RUNAS_UID" ]
then
    if [ -n "$RUNAS_GID" ]
    then
        echo "Switching to user $RUNAS_UID and group $RUNAS_GID"
        PRIVDROP="setpriv --reuid=$RUNAS_UID --regid=$RUNAS_GID --clear-groups"
    else
        echo "Switching to user $RUNAS_UID"
        PRIVDROP="setpriv --reuid=$RUNAS_UID"
    fi
    echo "Dropping privileges to $($PRIVDROP id -u):$($PRIVDROP id -g)"
fi

# Hand off to the CMD
exec ${PRIVDROP} "$@"
