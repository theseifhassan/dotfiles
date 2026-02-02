#!/bin/sh
# Display network status for dwmblocks
ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^yes' | cut -d: -f2)

if [ -n "$ssid" ]; then
    echo "NET: $ssid"
else
    iface=""
    for i in /sys/class/net/*/operstate; do
        [ "$(cat "$i" 2>/dev/null)" = "up" ] && iface=$(basename "$(dirname "$i")") && break
    done
    [ -n "$iface" ] && echo "NET: UP" || echo "NET: DOWN"
fi
