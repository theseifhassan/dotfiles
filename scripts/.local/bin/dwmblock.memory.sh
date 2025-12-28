#!/bin/sh
# Display memory usage (used/total)

case $BLOCK_BUTTON in
    1) 
        if pgrep -x btop >/dev/null; then
            pkill -x btop
        else
            command -v btop >/dev/null && ghostty --x11-instance-name=floating --window-width=160 --window-height=60 -e btop &
        fi
        ;;
esac

mem=$(free -h | awk '/^Mem/ { print $3"/"$2 }' | sed 's/Gi/G/g; s/Mi/M/g')
printf "MEM: %s\n" "$mem"
