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

temp_acc=$(mktemp)
temp_cert=$(mktemp)
cat "$temp_file" | while IFS= read -r line; do
    decoded_line=$(echo "$line" | base64 --decode)
    # echo "Line: $decoded_line"
    CERT_DOMAINS=$(echo "$decoded_line" | jq -r ".domains | join(\",\")")
    # echo "Domains: $CERT_DOMAINS"
    CERT_DOMAIN=$(echo "$decoded_line" | jq -r '.domains[0] | sub("^\\*\\."; "")')
    # echo "Domain: $CERT_DOMAIN"
    ACCOUNT_EMAIL=$(echo "$decoded_line" | jq  -r ".letsencrypt_email")
    LE_ENDPOINT=$(echo "$decoded_line" | jq  -r ".endpoint")
    HASH=$(echo "$CERT_DOMAINS" | sha256sum | cut -c1-8)
    ACCOUNT_NAME="$ACCOUNT_EMAIL-$HASH"
    # echo "Account: $ACCOUNT_NAME"
    CERT_NAME="$CERT_DOMAIN-$HASH"
    # echo "Cert name: $CERT_NAME"
    DNS_PROVIDER=$(echo "$decoded_line" | jq -r ".dns_provider")
    DNS_ENV=$(echo "$decoded_line" | jq -r '.dns_env | to_entries | map("\(.key) = \(.value | tojson)") | join(", ")')

    sed -e "s/ACCOUNT_EMAIL/$ACCOUNT_EMAIL/g" \
        -e "s/ACCOUNT_NAME/$ACCOUNT_NAME/g" \
        ./certs/acmed/acmed.account.toml | base64 >>"$temp_acc"

    sed -e "s/CERT_NAME/$CERT_NAME/g" \
        -e "s/CERT_DOMAINS/$CERT_DOMAINS/g" \
        -e "s/DNS_PROVIDER/$DNS_PROVIDER/g" \
        -e "s/CERT_DOMAIN/$CERT_DOMAIN/g" \
        -e "s/CERT_ACCOUNT/$ACCOUNT_NAME/g" \
        -e "s/LE_ENDPOINT/$LE_ENDPOINT/g" \
        -e "s/, PROVIDER_VARS = \"\"/, $DNS_ENV/g" \
        ./certs/acmed/acmed.cert.toml | base64 >> "$temp_cert"
done

if [ ! -f "$config_file" ]; then
    echo "error: $config_file is not a file"
    exit 1
fi

sed -e "s/\"LE_TOS_AGREED\"/$LE_TOS_AGREED/g" \
    "./certs/acmed/acmed.base.toml" > "${output_file}"
# cat "${output_file}"
awk '!seen[$0]++ {print | "base64 --decode"}' "$temp_acc" >> "$output_file"
awk '!seen[$0]++ {print | "base64 --decode"}' "$temp_cert" >> "$output_file"

rm "$temp_file"
rm "$temp_acc"
rm "$temp_cert"
