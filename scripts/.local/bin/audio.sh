#!/bin/sh
# Interactive dmenu audio device switcher
# Usage: audio.sh [input|output]
#   input  - Select microphone/input device
#   output - Select speaker/output device
#   (no arg) - Show main menu

case "$1" in
    input)
        choice=$(wpctl status | awk '/Sources:/,/Filters:/ {if (/^ │/) print}' | sed 's/^[│ ]*//; s/ *\[.*\]//; s/^\* \(.*\)/\1 */; s/^  \(.*\)/\1/' | dmenu -l 4 -p "Input:")
        [ -n "$choice" ] && wpctl set-default "$(echo "$choice" | sed 's/ \*$//' | awk '{print $1}' | tr -d '.')" && pkill -RTMIN+10 dwmblocks
        ;;
    output)
        choice=$(wpctl status | awk '/Sinks:/,/Sources:/ {if (/^ │/) print}' | sed 's/^[│ ]*//; s/ *\[.*\]//; s/^\* \(.*\)/\1 */; s/^  \(.*\)/\1/' | dmenu -l 4 -p "Output:")
        [ -n "$choice" ] && wpctl set-default "$(echo "$choice" | sed 's/ \*$//' | awk '{print $1}' | tr -d '.')" && pkill -RTMIN+10 dwmblocks
        ;;
    *)
        choice=$(printf "input\noutput\n" | dmenu -p "Audio:")
        [ -n "$choice" ] && "$0" "$choice"
        ;;
esac
