#!/bin/sh
# Display audio volume or mute status

case $BLOCK_BUTTON in
    1) 
        if pgrep -x wiremix >/dev/null; then
            pkill -x wiremix
        else
            command -v wiremix >/dev/null && floating-term 60 20 wiremix &
        fi
        ;;
esac

vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit
echo "$vol" | grep -q MUTED && echo "VOL: MUTED" || echo "VOL: $(echo "$vol" | awk '{print int($2*100)}')%"
