#!/bin/sh
# Display currently playing media

command -v playerctl >/dev/null || exit 0

status=$(playerctl status 2>/dev/null) || exit 0
[ "$status" = "Playing" ] && prefix=">" || prefix="||"

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

output="$prefix $title - $artist"
[ ${#output} -gt 40 ] && output="$(echo "$output" | cut -c1-37)..."

echo "$output"
