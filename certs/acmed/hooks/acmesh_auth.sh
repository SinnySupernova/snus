#!/bin/sh

log_file=/hook-logs/acmesh.log

echo "domain: $1" >> $log_file
echo "dns provider: $dns_provider" >> $log_file

wildcard=$1
proof=$2

acme="_acme-challenge"
dom=${wildcard#"*."}

acmesh_path="/acmesh"

# source acme.sh
. "${acmesh_path}/acme.sh" > /dev/null

# source the dns api
. "${acmesh_path}/dnsapi/${dns_provider}.sh" > /dev/null

# add record
"${dns_provider}_add" "${acme}.${dom}" "${proof}" >> $log_file 2>&1

# wait for propagation
max_wait=900
interval=60
elapsed=0

while [ $elapsed -lt $max_wait ]; do
    if dig +short TXT "${acme}.${dom}" | grep -q "\"${proof}\""; then
        # echo "DNS propagation detected."
        break
    fi
    # echo "Waiting for DNS propagation... (${elapsed}/${max_wait}s)"
    sleep $interval
    elapsed=$((elapsed + interval))
done
