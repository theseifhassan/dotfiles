#!/bin/sh
set -e
# Web app manager - create and remove web app .desktop entries
# Launch apps via dmenu (mod+p) - they appear alongside regular applications

APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
BROWSER="${BROWSER:-google-chrome-stable}"

mkdir -p "$APPS"

list_apps() {
    grep -l "^Exec=.*--app=" "$APPS"/*.desktop 2>/dev/null | while read -r f; do
        grep '^Name=' "$f" | cut -d= -f2-
    done | sort
}

create() {
    input=$(echo "" | dmenu -i -p "name|url:")
    [ -z "$input" ] && exit 0

    IFS='|' read -r name url <<EOF
$input
EOF
    [ -z "$name" ] || [ -z "$url" ] && { notify-send "Error" "Format: name|url"; exit 1; }
    echo "$url" | grep -q "^https\?://" || url="https://$url"

    safe=$(echo "$name" | tr -cd '[:alnum:]._-')
    desktop="$APPS/$safe.desktop"

    [ -f "$desktop" ] && { notify-send "Error" "Already exists"; exit 1; }

    url_escaped=$(printf '%s' "$url" | sed "s/'/'\\\\''/g; s/\"/\\\\\"/g; s/%/%%/g")

    cat > "$desktop" <<EOF
[Desktop Entry]
Name=$name
Exec=$BROWSER --app='$url_escaped' --class="$safe"
Type=Application
Icon=google-chrome
StartupWMClass=$safe
EOF
    chmod 644 "$desktop"
    notify-send "Web App" "Created: $name"
}

remove() {
    apps=$(list_apps)
    [ -z "$apps" ] && { notify-send "Web Apps" "No apps found"; exit 0; }

    sel=$(echo "$apps" | dmenu -i -p "Remove:")
    [ -z "$sel" ] && exit 0

    [ "$(printf "No\nYes" | dmenu -i -p "Remove $sel?")" != "Yes" ] && exit 0

    file=$(grep -l "^Name=$sel$" "$APPS"/*.desktop 2>/dev/null | head -1)
    [ -z "$file" ] && { notify-send "Error" "App not found"; exit 1; }

    rm -f "$file" && notify-send "Web App" "Removed: $sel"
}

case "${1:-}" in
    create|add) create ;;
    remove|rm) remove ;;
    list|ls) list_apps ;;
    *)
        choice=$(printf "Create\nRemove\nList" | dmenu -i -p "Web Apps:")
        case "$choice" in
            Create) create ;;
            Remove) remove ;;
            List) list_apps | xargs -I{} notify-send "Web Apps" "{}" ;;
        esac
        ;;
esac
