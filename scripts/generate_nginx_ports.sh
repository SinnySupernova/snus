#!/bin/sh

set -eu

NGINX_PORTS="$1"

if [ -z "$NGINX_PORTS" ]; then
  echo "error: NGINX_PORTS is empty, please provide valid ports"
  exit 1
fi

PORTS=$(echo "$NGINX_PORTS" | tr ',' ' ')

OUTPUT_FILE="$2"

{
    echo "services:"
    echo "  nginx:"
    echo "    ports:"
    for PORT in $PORTS; do
        echo "      - $PORT"
    done
} > "$OUTPUT_FILE"
