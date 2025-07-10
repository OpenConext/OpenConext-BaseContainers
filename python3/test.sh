#!/bin/bash
echo "Build image"
docker build -t python3:test . --no-cache

echo
echo "Remove old container"
docker rm python3

# With RUNAS_UID and RUNAS_GID
echo
echo "Run image with env"
docker run --name python3 --env RUNAS_UID=10001 --env RUNAS_GID=10001 python3:test

# Without RUNAS_UID and RUNAS_GID
# echo
# echo "Run without env"
# docker run --name python3 python3:mve

echo
echo "Start container"
docker start -i python3
