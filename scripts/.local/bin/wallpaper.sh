#!/bin/sh

# Wallpaper rotation script
# Randomly selects and sets a wallpaper from ~/Pictures/Wallpapers

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/current_wallpaper"

# Get random wallpaper (exclude current if possible)
get_random_wallpaper() {
    current=""
    [ -f "$CACHE_FILE" ] && current=$(cat "$CACHE_FILE")
    
    wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | \
        grep -v "$current" | shuf -n 1)
    
    # Fallback if only one wallpaper or grep removed all
    [ -z "$wallpaper" ] && wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | shuf -n 1)
    
    echo "$wallpaper"
}

set_wallpaper() {
    wallpaper="$1"
    [ -z "$wallpaper" ] && exit 1
    
    feh --bg-fill "$wallpaper"
    echo "$wallpaper" > "$CACHE_FILE"
}

case "$1" in
    next|"")
        set_wallpaper "$(get_random_wallpaper)"
        ;;
    current)
        [ -f "$CACHE_FILE" ] && cat "$CACHE_FILE"
        ;;
    *)
        echo "Usage: wallpaper.sh [next|current]"
        ;;
esac
