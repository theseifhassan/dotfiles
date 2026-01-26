#!/bin/sh
set -e
# Take screenshots with scrot, copy to clipboard and save to disk
# Usage: screenshot.sh [select]
#   select - Select region to capture (omit for full screen)

command -v scrot >/dev/null || { echo "scrot required"; exit 1; }
command -v xclip >/dev/null || { echo "xclip required"; exit 1; }

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

if [ "$1" = "select" ]; then
    scrot -s "$FILE"
else
    scrot "$FILE"
fi

# Copy to clipboard and notify
xclip -selection clipboard -target image/png -i "$FILE"
notify-send --icon=blank "Screenshot" "Saved to $FILE"
