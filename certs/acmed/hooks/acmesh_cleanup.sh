#!/bin/sh

set -eu

log_file=/hook-logs/acmesh.log

echo "dns cleanup for domain: $1" >> $log_file

wildcard=$1
proof=$2

acme="_acme-challenge"
dom=${wildcard#"*."}

acmesh_path="/acmesh"

# source acme.sh
. "${acmesh_path}/acme.sh" > /dev/null

# source the dns api
. "${acmesh_path}/dnsapi/${dns_provider}.sh" > /dev/null

# remove record
"${dns_provider}_rm" "${acme}.${dom}" "${proof}" >> $log_file 2>&1
