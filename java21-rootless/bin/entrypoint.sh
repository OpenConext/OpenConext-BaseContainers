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

if [ -n "${JAVA_UID:-}" ] || [ -n "${JAVA_GID:-}" ]; then
    echo "WARNING: JAVA_UID / JAVA_GID are ignored by this image." >&2
    echo "         The uid/gid are fixed at build time (USER_UID / USER_GID build args)." >&2
    echo "         For a one-off override use: docker run --user #<uid>:#<gid>" >&2
fi

# Hand off to CMD
exec "$@"