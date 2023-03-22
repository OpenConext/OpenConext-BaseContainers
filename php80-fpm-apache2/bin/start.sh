#!/usr/bin/env bash

# Read the application environment from the parameters
APP_ENV=$1

# Start PHP-Fpm in the background
service php8.0-fpm start

# Start Apache2 in the background
service apache2 start

# Tail the Apache2 and PHP-Fpm logs
tail -f /var/log/apache2/*.log /var/log/php8.0-fpm.log

