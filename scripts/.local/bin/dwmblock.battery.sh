#!/bin/sh
# Display battery charge status and percentage

bat=/sys/class/power_supply/BAT0
[ ! -d "$bat" ] && echo "AC" && exit
read -r cap < "$bat/capacity"
read -r status < "$bat/status"
[ "$status" = "Charging" ] && echo "CHA: $cap%" || echo "BAT: $cap%"
