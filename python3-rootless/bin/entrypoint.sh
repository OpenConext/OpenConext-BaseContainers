#!/bin/bash
set -e

if [[ -v DEBUG ]]; then
    set -x
fi

# This image is intended to run without root. The unprivileged user
# was created at build time (see USER_UID / USER_GID build args), so
# there is nothing to set up at start. Warn (but allow) if it is
# overridden to run as root anyway, e.g. for debugging.
if [ "$(id -u)" = "0" ]; then
    echo "WARNING: this image is intended to run without root." >&2
    echo "          You are running as root (e.g. via --user root)." >&2
fi

# run custom scripts in /container-init and /container-init-post as
# the current (unprivileged) user
if [ -d "/container-init" ]; then
    run-parts --verbose --regex '.*' "/container-init"
fi
if [ -d "/container-init-post" ]; then
    run-parts --verbose --regex '.*' "/container-init-post"
fi

# Hand off to CMD
exec "$@"