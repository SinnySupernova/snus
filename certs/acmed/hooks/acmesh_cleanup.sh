#!/bin/sh

wildcard=$1
proof=$2

acme="_acme-challenge"
dom=${wildcard#"*."}

acmesh_path="/acmesh"

# source acme.sh
. "${acmesh_path}/acme.sh" > /dev/null

# source the dns api
. "${acmesh_path}/dnsapi/${DNS_PROVIDER}.sh" > /dev/null

# remove record
"${DNS_PROVIDER}_rm" "${acme}.${dom}" "${proof}" >> $log_file 2>&1
