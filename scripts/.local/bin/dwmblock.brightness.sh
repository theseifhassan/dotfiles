#!/bin/sh
# Display screen brightness percentage

command -v brightnessctl >/dev/null 2>&1 || {
    echo "BRI: N/A"
    exit 0
}

current=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( current * 100 / max ))
printf "BRI: %d%%\n" "$pct"
