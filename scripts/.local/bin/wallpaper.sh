#!/bin/sh
# Rotate wallpaper from ~/Pictures/Wallpapers using feh
# Can be run manually or via systemd timer

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR" >&2
    exit 1
fi

# Pick a random wallpaper
wallpaper=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | shuf -n 1)

[ -z "$wallpaper" ] && exit 1

feh --bg-fill "$wallpaper"
