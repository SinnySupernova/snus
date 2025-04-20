#!/bin/sh

set -eu

log_file=/hook-logs/acmesh.log

echo "dns auth for domain: $1" >> $log_file
echo "dns provider: $dns_provider" >> $log_file

wildcard=$1
proof=$2

acme="_acme-challenge"
dom=${wildcard#"*."}

acmesh_path="/acmesh"

set +u

# source acme.sh
. "${acmesh_path}/acme.sh" > /dev/null

# source the dns api
. "${acmesh_path}/dnsapi/${dns_provider}.sh" > /dev/null

set -u

# add record
"${dns_provider}_add" "${acme}.${dom}" "${proof}" >> $log_file 2>&1

# wait for propagation
max_wait=900
interval=20
elapsed=0

while [ $elapsed -lt $max_wait ]; do
    if dig +short TXT "${acme}.${dom}" | grep -q "\"${proof}\""; then
        echo "DNS propagation detected." >> $log_file
        exit 0
    fi
    echo "Waiting for DNS propagation... (${elapsed}/${max_wait}s)" >> $log_file
    sleep $interval
    elapsed=$((elapsed + interval))
done

echo "DNS propagation failed after ${max_wait}s. Aborting" >> $log_file
exit 1
