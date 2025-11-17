#!/bin/sh
# Display audio volume or mute status

vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit
echo "$vol" | grep -q MUTED && echo "VOL: MUTED" || echo "VOL: $(echo "$vol" | awk '{print int($2*100)}')%"
