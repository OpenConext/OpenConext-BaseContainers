#!/usr/bin/env bash

# Start PHP-FPM in the background, but still it will output messages to STDOUT
php-fpm &

# Start Apache2 in the background, tail its logs so they get printed to STDOUT
apache2ctl start
tail -f /var/log/apache2/*.log
