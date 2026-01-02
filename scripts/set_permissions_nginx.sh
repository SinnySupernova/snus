#!/bin/sh

set -eu

NGINX_GID=$1

if [ -z "${NGINX_GID}" ]; then
    echo "error: set_permissions_nginx 1st argument is the nginx gid" >&2
    exit 1
fi

for dir in ./nginx/conf.d ./nginx/stream-conf.d; do
    setfacl -m g:${NGINX_GID}:rX "$dir" # rX on the dir
    setfacl -dm g:${NGINX_GID}:rX "$dir" # rX on new files in the dir
    find "$dir" -type f -user $(id -u) -exec setfacl -m g:${NGINX_GID}:rX {} \; # rX on files in the dir created by host user
done
