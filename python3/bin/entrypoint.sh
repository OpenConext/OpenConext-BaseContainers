#!/usr/bin/env bash
set -e

if [[ -v DEBUG  ]]
then
    set -x
fi

# handle privilege dropping
if [ $UID -ne 0 ]
then
    echo "This container need to run as root"
    echo "Use USER/GROUP environment variables to specify the uid/gid to run as"

    exit 1
fi

# run custom scripts before dropping privileges
echo "Running custom scripts in /container-init as root"
if [ -d "/container-init" ]
then
    # run all scripts using run-parts
    run-parts --verbose --regex '.*' "/container-init"
fi

# set up privilege dropping to user and group
PRIVDROP=
if [ -n "$RUNAS_UID" ]
then
    if [ -n "$RUNAS_GID" ]
    then
        echo "Switching to user $RUNAS_UID and group $RUNAS_GID"
        groupadd -g $RUNAS_GID openconext
        useradd -M -u $RUNAS_UID -g $RUNAS_GID openconext
        PRIVDROP="runuser --user=openconext --group=openconext -- "
    else
        echo "Switching to user $RUNAS_UID"
        useradd -M -u $RUNAS_UID openconext
        PRIVDROP="runuser --user=openconext -- "
    fi
    echo "Dropping privileges to $($PRIVDROP id -u):$($PRIVDROP id -g)"
fi

# run custom scripts after dropping privileges
echo "Running custom scripts in /container-init-post"
if  [ -d "/container-init-post" ]
then
    # run all scripts using run-parts
    ${PRIVDROP} run-parts --verbose --regex '.*' "/container-init-post"
fi

# Hand off to the CMD
exec ${PRIVDROP} "$@"
