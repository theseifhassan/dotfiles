#!/bin/sh
# Display memory usage (used/total)

case $BLOCK_BUTTON in
    1) 
        if pgrep -x btop >/dev/null; then
            pkill -x btop
        else
            command -v btop >/dev/null && floating-term 100 30 btop &
        fi
        ;;
esac

mem=$(free -h | awk '/^Mem/ { print $3"/"$2 }' | sed 's/Gi/G/g; s/Mi/M/g')
printf "MEM: %s\n" "$mem"
