#!/bin/sh
# Display active network interface

for i in /sys/class/net/*/operstate; do
    [ "$(cat "$i")" = "up" ] && iface=$(basename "$(dirname "$i")") && break
done
[ "$iface" ] && echo "NET: $iface" || echo "NET: Down"
