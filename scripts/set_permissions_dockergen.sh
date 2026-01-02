#!/bin/sh

set -eu

DOCKERGEN_GID=$1

if [ -z "${DOCKERGEN_GID}" ]; then
    echo "error: set_permissions_dockergen 1st argument is the dockergen gid" >&2
    exit 1
fi

setfacl -m g:${DOCKERGEN_GID}:r ./dockergen/nginx*.tmpl # r on templates
for dir in ./nginx/conf.d ./nginx/stream-conf.d; do
    setfacl -m g:${DOCKERGEN_GID}:rwX "$dir" # rwX on the dir
    setfacl -dm g:${DOCKERGEN_GID}:rwX "$dir" # rwX on new files in the dir
    setfacl -Rdm u:$(id -g):rwX "$dir" # rwX on new files in the dir for the host user
done
