#!/bin/sh

set -eu

NGINX_GID=$1

if [ -z "${NGINX_GID}" ]; then
    echo "error: set_permissions_nginx 1st argument is the nginx gid" >&2
    exit 1
fi

setfacl -m g:${NGINX_GID}:r ./nginx/conf.d
find ./nginx/conf.d -type f -user $(id -u) -exec setfacl -m g:${NGINX_GID}:r {} \;
setfacl -dm g:${NGINX_GID}:r ./nginx/conf.d
