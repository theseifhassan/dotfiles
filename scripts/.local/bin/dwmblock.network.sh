#!/bin/sh
# Display active network name

case $BLOCK_BUTTON in
    1) 
        if pgrep -x impala >/dev/null; then
            pkill -x impala
        else
            command -v impala >/dev/null && ghostty --x11-instance-name=floating --window-width=160 --window-height=60 -e impala &
        fi
        ;;
esac

# Try to get WiFi SSID
ssid=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d: -f2)

if [ -n "$ssid" ]; then
    echo "NET: $ssid"
else
    # Fallback to checking wired connection
    for i in /sys/class/net/*/operstate; do
        [ "$(cat "$i")" = "up" ] && iface=$(basename "$(dirname "$i")") && break
    done
    [ "$iface" ] && echo "NET: UP" || echo "NET: DOWN"
fi
