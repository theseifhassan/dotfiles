#!/bin/sh
# Display active network name

# Try to get WiFi SSID
ssid=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d: -f2)

if [ -n "$ssid" ]; then
    echo "NET: $ssid"
else
    # Fallback to checking wired connection
    for i in /sys/class/net/*/operstate; do
        [ "$(cat "$i")" = "up" ] && iface=$(basename "$(dirname "$i")") && break
    done
    [ "$iface" ] && echo "NET: $iface" || echo "NET: Down"
fi
