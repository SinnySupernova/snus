#!/bin/sh

set -eu

# $1 = repo download dir
# $2 = git repo url
# $3 = optional git branch

if [ -z "$1" ]; then
    echo "error: update_repo 1st argument is the target directory" >&2
    exit 1
fi
if [ -z "$2" ]; then
    echo "error: update_repo 2st argument is the git repo url" >&2
    exit 1
fi

if [ -d "$1" ] && [ "$(git -C "$1" remote get-url origin)" != "$2" ]; then
    rm -rf "$1"
fi
if [ ! -d "$1" ]; then
    git clone --depth=1 "$2" "$1"
fi
if [ "$#" -ge 3 ] && [ "$(git -C "$1" rev-parse --abbrev-ref HEAD)" != "$3" ]; then
    git -C "$1" fetch origin "$3":"$3"
    git -C "$1" checkout "$3"
fi
git -C "$1" pull
