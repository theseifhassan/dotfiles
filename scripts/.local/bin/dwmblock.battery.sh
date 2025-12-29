#!/bin/sh
[ "$(cat "${XDG_RUNTIME_DIR:-/tmp}/statusbar-mode" 2>/dev/null)" = "minimal" ] && exit
bat=/sys/class/power_supply/BAT0
[ -d "$bat" ] || exit

mode=$(case "$(powerprofilesctl get 2>/dev/null)" in
    balanced) echo B ;; power-saver) echo E ;; performance) echo P ;; *) echo B ;;
esac)

read -r cap < "$bat/capacity"
read -r status < "$bat/status"
[ "$status" = "Charging" ] && echo "CHR[$mode]: $cap%" || echo "BAT[$mode]: $cap%"
