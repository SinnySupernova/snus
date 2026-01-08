#! /bin/sh

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Error: docker-compose is not installed."
    exit 1
fi

CURRENT_VERSION=$(docker-compose version --short 2>/dev/null | sed 's/^v//')

if ! echo "$CURRENT_VERSION" | grep -q "^[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}"; then
    echo "Error: 'docker-compose version' produced an invalid or unexpected format: '$CURRENT_VERSION'"
    exit 1
fi

REQUIRED_VERSION="5.0.0"

if ! [ "$(printf "$REQUIRED_VERSION\n$CURRENT_VERSION" | sed '/-/!{s/$/_/}' | sort -V | sed 's/_$//' | tail -n-1)" = "$CURRENT_VERSION" ]; then
    echo "Error: docker-compose version $CURRENT_VERSION is lower than $REQUIRED_VERSION."
    exit 1
fi
