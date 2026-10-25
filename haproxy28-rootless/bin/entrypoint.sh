#!/bin/sh
set -e

# This image is intended to run without root. Warn (but allow) if it is
# overridden to run as root anyway, e.g. for debugging.
if [ "$(id -u)" = "0" ]; then
    echo "WARNING: this image is intended to run without root." >&2
    echo "          You are running as root (e.g. via --user root)." >&2
fi

# Hand off to CMD
exec "$@"