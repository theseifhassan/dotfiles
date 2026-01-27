#!/bin/sh
set -e
# Screenshot tool using maim (works properly with compositors)
# Usage: screenshot.sh [select|window]
#   select - Select region to capture
#   window - Capture focused window
#   (none) - Capture full screen

command -v maim >/dev/null || { notify-send "Error" "maim required"; exit 1; }

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

case "${1:-}" in
    select)
        maim -s -u "$FILE" || exit 0
        ;;
    window)
        maim -i "$(xdotool getactivewindow)" -u "$FILE"
        ;;
    *)
        maim -u "$FILE"
        ;;
esac

# Copy to clipboard and notify
xclip -selection clipboard -target image/png -i "$FILE"
notify-send "Screenshot" "Saved to $FILE"
