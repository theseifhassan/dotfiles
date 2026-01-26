#!/bin/sh
set -e
# Power profile selector using dmenu

command -v powerprofilesctl >/dev/null || { echo "power-profiles-daemon required"; exit 1; }
command -v dmenu >/dev/null || { echo "dmenu required"; exit 1; }

current=$(powerprofilesctl get 2>/dev/null || echo "unknown")

choice=$(printf "balanced\npower-saver\nperformance" | dmenu -p "Power [$current]:")

[ -n "$choice" ] && powerprofilesctl set "$choice"
