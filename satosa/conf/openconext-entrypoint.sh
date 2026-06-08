#!/usr/bin/env bash
set -euo pipefail

RUNAS_UID="${RUNAS_UID:-1000}"
RUNAS_GID="${RUNAS_GID:-1000}"

if ! getent passwd satosa >/dev/null 2>&1 || [ "$(getent passwd satosa | cut -d: -f3)" != "$RUNAS_UID" ]; then
  userdel -r satosa 2>/dev/null || userdel satosa 2>/dev/null || true
  if ! getent group satosa >/dev/null 2>&1 || [ "$(getent group satosa | cut -d: -f3)" != "$RUNAS_GID" ]; then
    groupdel satosa 2>/dev/null || true
    groupadd -g "$RUNAS_GID" satosa
  fi
  useradd -m -g satosa -u "$RUNAS_UID" satosa
fi

chown -R satosa:satosa /etc/satosa

exec setpriv --reuid=satosa --regid=satosa --init-groups --inh-caps=-all \
  docker-entrypoint.sh "$@"
