#!/bin/sh
# Power profile selector using dmenu

current=$(powerprofilesctl get 2>/dev/null || echo "unknown")

choice=$(printf "balanced\npower-saver\nperformance" | dmenu -p "Power [$current]:")

[ -n "$choice" ] && powerprofilesctl set "$choice"
