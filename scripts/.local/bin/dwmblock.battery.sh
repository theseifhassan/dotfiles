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
    esac
}

case $BLOCK_BUTTON in
    1) power-menu.sh & ;;
esac

icon=$(profile_icon)

if has_battery; then
    read -r cap < "$bat/capacity"
    read -r status < "$bat/status"
    suffix="${icon:+ [$icon]}"
    [ "$status" = "Charging" ] && echo "CHA: $cap%$suffix" || echo "BAT: $cap%$suffix"
elif [ -n "$icon" ]; then
    echo "PWR: $icon"
fi
