#!/bin/sh
# Display battery charge status and percentage

bat=/sys/class/power_supply/BAT0
[ ! -d "$bat" ] && exit 0

read -r cap < "$bat/capacity"
read -r status < "$bat/status"
[ "$status" = "Charging" ] && echo "CHA: $cap%" || echo "BAT: $cap%"
