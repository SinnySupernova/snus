#!/bin/sh

set -eu

CERTS_GID=$1

if [ -z "${CERTS_GID}" ]; then
    echo "error: set_permissions_certs 1st argument is the certs gid" >&2
    exit 1
fi

setfacl -m g:${CERTS_GID}:r ./certs/acmed/acmed.toml
setfacl -Rm g:${CERTS_GID}:rx ./certs/acmed/hooks
mkdir -p ./certs/acmed/hook-logs
setfacl -m g:${CERTS_GID}:rwx ./certs/acmed/hook-logs
setfacl -Rdm u:$(id -u):rwx ./certs/acmed/hook-logs
