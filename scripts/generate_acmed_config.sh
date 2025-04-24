#!/bin/sh

set -eu

config_file="./config.toml"
if [ ! -f "$config_file" ]; then
    echo "error: $config_file is not a file"
    exit 1
fi

output_file="./certs/acmed/acmed.toml"
if [ -e "$output_file" ]; then
    if [ ! -f "$output_file" ]; then
        echo "Error: $output_file exists but is not a regular file." >&2
        exit 1
    fi
    rm "$output_file"
fi

tq() { ${TQ_CMD} tq "$@"; }
jq() { ${TQ_CMD} jq "$@"; }

LE_TOS_AGREED=$(tq 'global.letsencrypt_tos_agree' < "$config_file" )

temp_file=$(mktemp)
tq 'certificate' -o json < "$config_file" | jq -r '.[] | @base64' > "$temp_file"

temp_cert_names=$(mktemp)
temp_acc=$(mktemp)
temp_cert=$(mktemp)
trap 'rm "$temp_file";rm "$temp_acc";rm "$temp_cert";rm "$temp_cert_names"' EXIT
cat "$temp_file" | while IFS= read -r line; do
    decoded_line=$(echo "$line" | base64 --decode)

    CERT_DOMAINS=$(echo "$decoded_line" | jq -r '.domains | join(" ")')

    LE_ENDPOINT=$(echo "$decoded_line" | jq  -r '.endpoint')

    ACCOUNT_EMAIL=$(echo "$decoded_line" | jq  -r '.letsencrypt_email')
    # accounts should be different per endpoint https://github.com/breard-r/acmed/wiki/Comptes
    ACCOUNT_NAME="$ACCOUNT_EMAIL-$LE_ENDPOINT"

    CERT_NAME="$(echo "$CERT_DOMAINS" | tr ' ' '+')-$LE_ENDPOINT"

    while IFS= read -r line; do
        if [ "$line" = "$CERT_NAME" ]; then
            echo "error: duplicate cert definition for domains: $CERT_DOMAINS" >&2
            exit 1
        fi
    done < "$temp_cert_names"
    echo $CERT_NAME >> "$temp_cert_names"

    DNS_PROVIDER=$(echo "$decoded_line" | jq -r '.dns_provider')

    # TODO allow using secrets for these vars
    DNS_ENV=$(echo "$decoded_line" | jq -r '.dns_env | to_entries | map("\(.key) = \(.value | tojson)") | join("\n")')

    sed -e "s/ACCOUNT_EMAIL/$ACCOUNT_EMAIL/g" \
        -e "s/ACCOUNT_NAME/$ACCOUNT_NAME/g" \
        ./certs/acmed/acmed.account.toml | base64 -w0 >> "$temp_acc"
    printf "\n" >> "$temp_acc"

    temp_temp_cert=$(mktemp)
    sed -e "s/CERT_NAME/$CERT_NAME/g" \
        -e "s/LE_ENDPOINT/$LE_ENDPOINT/g" \
        -e "s/CERT_ACCOUNT/$ACCOUNT_NAME/g" \
        -e "s/CERT_FILENAME/$CERT_NAME/g" \
        ./certs/acmed/acmed.cert.toml >> "$temp_temp_cert"
    for CERT_DOMAIN in $CERT_DOMAINS; do
        {
            sed -e "s/DNS_PROVIDER/$DNS_PROVIDER/g" \
                -e "s/CERT_DOMAIN/$CERT_DOMAIN/g" \
                ./certs/acmed/acmed.cert.identifiers.toml
            echo "$DNS_ENV" | sed 's/^/env./'
        } >> "$temp_temp_cert"
    done
    cat "$temp_temp_cert" | base64 -w0 >> "$temp_cert"
    rm "$temp_temp_cert"
    printf "\n" >> "$temp_cert"
done

sed -e "s/\"LE_TOS_AGREED\"/$LE_TOS_AGREED/g" \
    "./certs/acmed/acmed.base.toml" > "${output_file}"

awk '!seen[$0]++ { print $0 }' "$temp_acc" | base64 -d >> "$output_file"
awk '!seen[$0]++ { print $0 }' "$temp_cert" | base64 -d >> "$output_file"
