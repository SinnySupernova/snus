#!/bin/sh

set -eu

input_compose=$1
target_dir=$2

if [ -z "$input_compose" ] || [ -z "$target_dir" ]; then
    echo "Usage: $0 <input_compose> <target_dir>"
    exit 1
fi

if ! command -v podlet > /dev/null; then
    echo "command 'podlet' not found"
    exit 1
fi

# ensure empty dir
[ ! -d "$target_dir" ] && mkdir -p "$target_dir"
find "$target_dir" -mindepth 1 -delete

podlet_file=$(mktemp)
trap 'rm "$podlet_file"' EXIT

podlet compose "$input_compose" --pod > "$podlet_file"

current_file=""

while IFS= read -r line; do
    case "$line" in
        "#"*) # new file name
            current_file=$(echo "$line" | sed 's/^#[[:space:]]*//;s/[[:space:]]*$//')
            echo "Creating $target_dir/$current_file"
            : > "$target_dir/$current_file"
            ;;
        "---"*) # skip separators
            continue
            ;;
        *) # append lines
            if [ -n "$current_file" ]; then
                printf "%s\n" "$line" >> "$target_dir/$current_file"
            fi
            ;;
    esac
done < "$podlet_file"
