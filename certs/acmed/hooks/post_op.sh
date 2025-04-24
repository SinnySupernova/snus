#!/bin/sh

set -eu

log_file=/hook-logs/acmesh.log

is_success=$1
identifiers=$2

echo "post op success for identifiers '$identifiers' success: '$is_success'" >> $log_file

if [ "$is_success" != "true" ]; then
    exit 0
fi

CERT_DIR="/var/lib/acmed/certs"

rebuild_symlinks() {

    find "$CERT_DIR" -maxdepth 1 -type l \( -name '*.crt' -o -name '*.key' \) -exec rm -f {} +

    link_ext() {
        ext="$1"  # "crt" or "key"

        for file in "$CERT_DIR"/*."$ext"; do
            [ -e "$file" ] || continue
            [ -L "$file" ] && continue

            filename=$(basename "$file") # e.g. aaa+bbb.crt
            base="${filename%.$ext}" # e.g. aaa+bbb

            old_IFS=$IFS
            IFS='+'
            for domain in $base; do
                ln -sf "$filename" "$CERT_DIR/$domain.$ext"
            done
            IFS=$old_IFS
        done
    }

    link_ext crt
    link_ext key
}

echo "rebuilding symlinks" >> $log_file
rebuild_symlinks
