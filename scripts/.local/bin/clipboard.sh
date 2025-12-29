#!/bin/sh
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/clipboard_history"

mkdir -p "$(dirname "$HISTFILE")"
[ -f "$HISTFILE" ] || touch "$HISTFILE"
[ -s "$HISTFILE" ] || { notify-send "Clipboard" "Empty"; exit 0; }

selected=$(dmenu -i -l 10 -p "Clipboard:" < "$HISTFILE")
[ -z "$selected" ] && exit 0

printf '%s' "$selected" | xclip -selection clipboard
notify-send "Clipboard" "Copied"
