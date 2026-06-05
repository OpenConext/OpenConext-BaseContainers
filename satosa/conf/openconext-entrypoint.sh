#!/usr/bin/env bash
set -e

userdel satosa
rm -rf /home/satosa

groupadd -g $GID satosa
useradd -m -g $GID -u $UID satosa

chown -R satosa:satosa /etc/satosa

setpriv --reuid=satosa --regid=satosa --init-groups --inh-caps=-all docker-entrypoint.sh "$@"
