#!/bin/sh
# Display currently playing media with RTL text support

# Check dependencies
command -v playerctl >/dev/null 2>&1 || { echo "MED: N/A"; exit 0; }
command -v fribidi >/dev/null 2>&1 || { echo "MED: fribidi missing"; exit 1; }

# Start the hooks in background if not already running
if ! pgrep -f "playerctl -F metadata" >/dev/null 2>&1; then
    # Monitor metadata changes (track changes)
    playerctl -F metadata 2>/dev/null | while read -r _; do
        pkill dwmblocks -RTMIN+12
    done &
    
    # Monitor status changes (play/pause)
    playerctl -F status 2>/dev/null | while read -r _; do
        pkill dwmblocks -RTMIN+12
    done &
fi

# Get status
STATUS=$(playerctl status 2>/dev/null)

# Set prefix based on status
if [ "$STATUS" = "Playing" ]; then
    PREFIX="PLAY:"
else
    PREFIX="PAUS:"
fi

# Get artist and title, process through fribidi for Arabic text support, remove extra spaces
ARTIST=$(playerctl metadata --format "{{ artist }}" 2>/dev/null | tr -s ' ')
TITLE=$(playerctl metadata --format "{{ title }}" 2>/dev/null | tr -s ' ')

OUTPUT="$PREFIX $TITLE - $ARTIST"
PROCESSED=$(echo "$OUTPUT" | fribidi --nopad | tr -d '\n')

# Trim to 70 characters and add ellipsis if needed
if [ ${#PROCESSED} -gt 30 ]; then
    echo "${PROCESSED}" | cut -c1-27 | tr -d '\n'
    echo "..."
else
    echo "$PROCESSED"
fi
