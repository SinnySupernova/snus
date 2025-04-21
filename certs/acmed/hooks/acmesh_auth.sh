#!/bin/sh

log_file=/hook-logs/acmesh.log

echo "dns auth for domain '$1' with provider '$dns_provider'" >> $log_file

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

if [ "$?" != "0" ]; then
    _err "acme.sh ${dns_provider}_add failed" >> $log_file 2>&1
    exit 1
fi

_info "acme.sh ${dns_provider}_add succeeded" >> $log_file

# wait for propagation
max_wait=900
interval=15
elapsed=0

while [ $elapsed -lt $max_wait ]; do
    if dig +short TXT "${acme}.${dom}" | grep -q "\"${proof}\""; then
        _info "DNS propagation detected" >> $log_file
        exit 0
    fi
    _info "waiting for DNS propagation... (${elapsed}/${max_wait}s)" >> $log_file
    sleep $interval
    elapsed=$((elapsed + interval))
done

_err "DNS propagation failed after ${max_wait}s; aborting" >> $log_file 2>&1
exit 1
