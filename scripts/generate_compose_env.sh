#!/bin/sh

set -eu

config_file="./config.toml"
if [ ! -f "$config_file" ]; then
    echo "error: $config_file is not a file"
    exit 1
fi

tq() { ${TQ_CMD} tq "$@"; }
jq() { ${TQ_CMD} jq "$@"; }

write_env() {
    echo "$1=$2" >> ./env/.env.compose
}

make_path_explicit() {
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      /*) echo "$line" ;;
      *) echo "./$line" ;;
    esac
  done <<< "${1:-$(cat)}"
}


rm ./env/.env.compose

write_env NGINX_UID $(tq 'nginx.uid'< "$config_file")
write_env NGINX_GID $(tq 'nginx.gid'< "$config_file")

write_env CERTS_UID $(tq 'certs.uid'< "$config_file")
write_env CERTS_GID $(tq 'certs.gid'< "$config_file")

write_env DOCKERGEN_UID $(tq 'dockergen.uid'< "$config_file")
write_env DOCKERGEN_GID $(tq 'dockergen.gid'< "$config_file")

write_env NGINX_REPO_DIR $(tq -r 'nginx.repo'< "$config_file" | make_path_explicit)
write_env NGINX_FLAVOR $(tq 'nginx.flavor'< "$config_file")
write_env NGINX_CONTAINER_IP $(tq 'nginx.container_ip'< "$config_file")
write_env NGINX_SUBNET $(tq 'nginx.subnet'< "$config_file")

write_env ACMED_REPO_DIR $(tq -r 'certs.acmed_repo'< "$config_file" | make_path_explicit)
write_env ACMESH_REPO_DIR $(tq -r 'certs.acmesh_repo'< "$config_file" | make_path_explicit)

write_env DOCKERGEN_REPO_DIR $(tq -r 'dockergen.repo'< "$config_file" | make_path_explicit)

. ./env/.env.docker_sock # <- DOCKER_SOCK_GID
write_env DOCKER_SOCK_GID ${DOCKER_SOCK_GID}
