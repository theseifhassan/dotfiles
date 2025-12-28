#!/bin/sh
# Wallpaper rotation

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

[ ! -d "$WALLPAPER_DIR" ] && exit 1

wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | shuf -n 1)
[ -z "$wallpaper" ] && exit 1

feh --bg-fill "$wallpaper"
