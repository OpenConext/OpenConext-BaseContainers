#!/usr/bin/env bash

# Start PHP-FPM in the background
php-fpm &

# Start Apache2 in the background
apache2ctl start

# Tail all the necessary logs
tail -f /var/log/apache2/*.log /usr/local/var/log/php-fpm-*.log
