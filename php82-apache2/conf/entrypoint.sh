#!/bin/sh
# Copy and import the haproxy certificate

if [ -e /config/haproxy/haproxy.crt ]; then
	cp /config/haproxy/haproxy.crt /usr/local/share/ca-certificates/
	update-ca-certificates
fi
# Hand off to the CMD
exec "$@"
