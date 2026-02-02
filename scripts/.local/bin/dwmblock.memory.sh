#!/bin/sh
# Display memory usage for dwmblocks
[ "$(cat "${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode" 2>/dev/null)" = "minimal" ] && exit
mem=$(free -h | awk '/^Mem/ { print $3"/"$2 }' | sed 's/Gi/G/g; s/Mi/M/g')
printf "MEM: %s\n" "$mem"
