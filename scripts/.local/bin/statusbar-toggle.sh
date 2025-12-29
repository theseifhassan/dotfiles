#!/bin/sh
# Toggle between minimal and full statusbar
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode"
DWMBLOCKS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/../dotfiles/dwmblocks"

current=$(cat "$STATE_FILE" 2>/dev/null || echo "full")

if [ "$current" = "full" ]; then
    echo "minimal" > "$STATE_FILE"
else
    echo "full" > "$STATE_FILE"
fi

# Signal all blocks to refresh (they check the mode)
pkill -RTMIN+10 dwmblocks
pkill -RTMIN+11 dwmblocks
pkill -RTMIN+13 dwmblocks
pkill -RTMIN+14 dwmblocks
pkill -RTMIN+15 dwmblocks
