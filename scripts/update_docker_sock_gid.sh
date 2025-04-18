#!/bin/sh

set -eu

container_runtime=$1

if [ "$container_runtime" = "podman" ]; then
    DOCKER_SOCK_PATH=$(podman info --format "{{.Host.RemoteSocket.Path}}")
else
    USER_SOCK="/run/user/$(id -u)/docker.sock" # rootless docker
    SYSTEM_SOCK="/var/run/docker.sock" # rootful docker

    if [ -S "$USER_SOCK" ]; then
        DOCKER_SOCK_PATH="$USER_SOCK"
    elif [ -S "$SYSTEM_SOCK" ]; then
        DOCKER_SOCK_PATH="$SYSTEM_SOCK"
    else
        echo "Error: no valid Docker socket found!" >&2
        exit 1
    fi
fi

mkdir -p ./env
printf "\
############### DO NOT EDIT ###############\n\
## this file was generated automatically ##\n\
###########################################\n\
DOCKER_SOCK_GID=$(stat -c '%g' "$DOCKER_SOCK_PATH")\n\
DOCKER_SOCK_PATH=$DOCKER_SOCK_PATH" > ./env/.env.docker_sock
