#!/usr/bin/env bash

# Start Apache2
apache2 -D FOREGROUND &

# Start Shibboleth
/usr/sbin/shibd -f -F -c /etc/shibboleth/shibboleth2.xml -p /run/shibboleth/shibd.pid -w 30
