#!/bin/sh

set -eu

DOCKERGEN_GID=$1

if [ -z "${DOCKERGEN_GID}" ]; then
    echo "error: set_permissions_dockergen 1st argument is the dockergen gid" >&2
    exit 1
fi

setfacl -m g:${DOCKERGEN_GID}:r ./dockergen/nginx.tmpl
setfacl -m g:${DOCKERGEN_GID}:rwx ./nginx/conf.d
setfacl -Rdm u:$(id -g):rw ./nginx/conf.d
