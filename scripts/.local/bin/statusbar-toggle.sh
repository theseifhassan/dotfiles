#!/bin/sh
# Toggle dwmblocks statusbar visibility
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode"

[ "$(cat "$STATE_FILE" 2>/dev/null)" = "full" ] && echo "minimal" > "$STATE_FILE" || echo "full" > "$STATE_FILE"

pkill -RTMIN+10 dwmblocks
pkill -RTMIN+11 dwmblocks
pkill -RTMIN+13 dwmblocks
pkill -RTMIN+14 dwmblocks
pkill -RTMIN+15 dwmblocks
