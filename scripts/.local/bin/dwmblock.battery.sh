#!/bin/sh
# Display battery/power status
# Click to open power profile menu

bat=/sys/class/power_supply/BAT0
has_battery() { [ -d "$bat" ]; }

profile_icon() {
    case "$(powerprofilesctl get 2>/dev/null)" in
        balanced)     echo "BAL" ;;
        power-saver)  echo "ECO" ;;
        performance)  echo "PRF" ;;
        *)            echo "" ;;
    esac
}

case $BLOCK_BUTTON in
    1) power-menu.sh ;;
esac

icon=$(profile_icon)
suffix="${icon:+ [$icon]}"

if has_battery; then
    read -r cap < "$bat/capacity"
    read -r status < "$bat/status"
    [ "$status" = "Charging" ] && echo "CHA: $cap%$suffix" || echo "BAT: $cap%$suffix"
else
    [ -n "$icon" ] && echo "PWR: $icon"
fi
