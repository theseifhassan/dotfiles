#!/bin/sh
# Skip in minimal mode
[ "$(cat "${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode" 2>/dev/null)" = "minimal" ] && exit

# Skip if no backlight (desktop)
[ -d /sys/class/backlight ] && [ "$(ls -A /sys/class/backlight 2>/dev/null)" ] || exit 0

command -v brightnessctl >/dev/null 2>&1 || exit 0

current=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( current * 100 / max ))
printf "BRI: %d%%\n" "$pct"
