#!/bin/sh

nproc=$(nproc)
export nproc
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc))
else
    threads=1
    slabs=4
fi

if [ ! -f /etc/unbound/unbound.conf ]; then
    sed -e "s/num-threads: 1/num-threads: ${threads}/" /etc/unbound/unbound-orig.conf
    mv /etc/unbound/unbound-orig.conf /etc/unbound/unbound.conf
fi

exec su-exec $UID:$GID /sbin/tini -- unbound
