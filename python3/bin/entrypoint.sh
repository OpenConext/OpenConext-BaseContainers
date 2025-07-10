#!/usr/bin/env bash
DEFAULT_UID=10000
DEFAULT_GID=10000

set -e

if [[ -v DEBUG  ]]
then
    set -x
fi

# Function to create user and group if needed
create_user_and_group() {
    local uid="$1"
    local gid="$2"
    local username="openconext"
    local groupname="openconext"

    # Check if the group already exists (when gid is provided)
    if [ -n "$gid" ]; then
        if getent group "$groupname" > /dev/null 2>&1; then
            # Group exists, check if GID matches
            existing_gid=$(getent group "$groupname" | cut -d: -f3)
            if [ "$existing_gid" != "$gid" ]; then
                echo "ERROR: Group '$groupname' already exists with GID $existing_gid, but requested GID is $gid" >&2
                echo "       Please recreate the container with the updated gid" >&2
                exit 1
            fi
            echo "Group '$groupname' already exists with correct GID $gid" >&2
        else
            # Group doesn't exist, create it
            echo "Creating group '$groupname' with GID $gid" >&2
            groupadd -g "$gid" "$groupname"
        fi
    fi

    # Check if the user already exists
    if getent passwd "$username" > /dev/null 2>&1; then
        # User exists, check if UID matches
        existing_uid=$(getent passwd "$username" | cut -d: -f3)
        if [ "$existing_uid" != "$uid" ]; then
            echo "ERROR: User '$username' already exists with UID $existing_uid, but requested UID is $uid" >&2
            echo "       Please recreate the container with the updated uid" >&2
            exit 1
        fi

        # If GID is provided, check if user's primary group matches
        if [ -n "$gid" ]; then
            existing_primary_gid=$(getent passwd "$username" | cut -d: -f4)
            if [ "$existing_primary_gid" != "$gid" ]; then
                echo "ERROR: User '$username' already exists with primary GID $existing_primary_gid, but requested GID is $gid" >&2
                echo "       Please recreate the container with the updated gid" >&2
                exit 1
            fi
        fi

        echo "User '$username' already exists with correct UID $uid" >&2
    else
        # User doesn't exist, create it
        if [ -n "$gid" ]; then
            echo "Creating user '$username' with UID $uid and GID $gid" >&2
            useradd -M -u "$uid" -g "$gid" "$username"
        else
            echo "Creating user '$username' with UID $uid" >&2
            useradd -M -u "$uid" "$username"
        fi
    fi

    # Return the appropriate privilege dropping command
    if [ -n "$gid" ]; then
        echo "runuser --user=$username --group=$groupname -- "
    else
        echo "runuser --user=$username -- "
    fi
}


# handle privilege dropping
if [ $UID -ne 0 ]
then
    echo "This container need to run as root"
    echo "Use USER/GROUP environment variables to specify the uid/gid to run as"

    exit 1
fi

# set up privilege dropping to user and group
PRIVDROP=$(create_user_and_group "${RUNAS_UID:-$DEFAULT_UID}" "${RUNAS_GID:-$DEFAULT_GID}")
echo "Dropping privileges to $($PRIVDROP id -u):$($PRIVDROP id -g)"

# run custom scripts before dropping privileges
echo "Running custom scripts in /container-init as root"
if [ -d "/container-init" ]
then
    # run all scripts using run-parts
    run-parts --verbose --regex '.*' "/container-init"
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
