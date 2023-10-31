#!/usr/bin/env bash

# Read the envars for Apache2
source /etc/apache2/envvars

# Start Apache2
apache2 -D FOREGROUND
