#!/bin/sh
[ "$(cat "${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode" 2>/dev/null)" = "minimal" ] && exit

# Find first battery (BAT0, BAT1, etc.)
for b in /sys/class/power_supply/BAT*; do
    [ -d "$b" ] && { bat="$b"; break; }
done
[ -z "$bat" ] && exit

mode=$(case "$(powerprofilesctl get 2>/dev/null)" in
    balanced) echo B ;; power-saver) echo E ;; performance) echo P ;; *) echo B ;;
esac)

read -r cap < "$bat/capacity" 2>/dev/null || exit
read -r status < "$bat/status" 2>/dev/null || status="Discharging"
[ "$status" = "Charging" ] && echo "CHR[$mode]: $cap%" || echo "BAT[$mode]: $cap%"
