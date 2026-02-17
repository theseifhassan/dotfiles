#!/bin/sh
# Toggle dwmblocks statusbar visibility
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode"

if [ "$(cat "$STATE_FILE" 2>/dev/null)" = "full" ]; then
    printf "minimal" > "$STATE_FILE"
else
    printf "full" > "$STATE_FILE"
fi

for sig in 10 11 13 14 15; do
    pkill -RTMIN+"$sig" dwmblocks
done
