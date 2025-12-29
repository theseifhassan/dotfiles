#!/bin/sh
set -e

ICONS="$HOME/.local/share/applications/icons"
APPS="$HOME/.local/share/applications"
BROWSER="chromium"

mkdir -p "$ICONS" "$APPS"

get_apps() { grep -l "^Exec=.*--app=" "$APPS"/*.desktop 2>/dev/null | while read f; do grep '^Name=' "$f" | cut -d= -f2-; done | sort; }

create() {
    input=$(echo "" | dmenu -i -p "name|url|icon:")
    [ -z "$input" ] && exit 0

    IFS='|' read -r name url icon <<EOF
$input
EOF
    [ -z "$name" ] || [ -z "$url" ] || [ -z "$icon" ] && { notify-send "Error" "All fields required"; exit 1; }
    echo "$url" | grep -q "^https\?://" || url="https://$url"

    safe=$(echo "$name" | tr -cd '[:alnum:]._-')
    desktop="$APPS/$safe.desktop"
    iconpath="$ICONS/$safe.${icon##*.}"
    iconpath="${iconpath%%\?*}"

    [ -f "$desktop" ] && { notify-send "Error" "Already exists"; exit 1; }
    curl -sL --max-time 30 -o "$iconpath" "$icon" || { notify-send "Error" "Icon download failed"; exit 1; }
    [ -s "$iconpath" ] || { rm -f "$iconpath"; notify-send "Error" "Empty icon"; exit 1; }

    cat > "$desktop" <<EOF
[Desktop Entry]
Name=$name
Exec=$BROWSER --app="$url" --class="$safe"
Type=Application
Icon=$iconpath
StartupWMClass=$safe
EOF
    chmod 644 "$desktop"
    notify-send "Created" "$name"
}

remove() {
    apps=$(get_apps)
    [ -z "$apps" ] && { notify-send "No apps"; exit 0; }
    sel=$(echo "$apps" | dmenu -i -p "Remove:")
    [ -z "$sel" ] && exit 0
    [ "$(printf "No\nYes" | dmenu -i -p "Remove $sel?")" != "Yes" ] && exit 0

    file=$(grep -l "^Name=$sel$" "$APPS"/*.desktop 2>/dev/null | head -1)
    icon=$(grep '^Icon=' "$file" 2>/dev/null | cut -d= -f2-)
    rm -f "$file" "$icon"
    notify-send "Removed" "$sel"
}

launch() {
    apps=$(get_apps)
    [ -z "$apps" ] && { notify-send "No apps"; exit 0; }
    sel=$(echo "$apps" | dmenu -i -p "Launch:")
    [ -z "$sel" ] && exit 0

    file=$(grep -l "^Name=$sel$" "$APPS"/*.desktop 2>/dev/null | head -1)
    [ -z "$file" ] && { notify-send "Error" "App not found"; exit 1; }
    dex "$file" &
}

case "${1:-}" in
    create|add) create ;;
    remove|rm) remove ;;
    launch|run) launch ;;
    list|ls) get_apps ;;
    *)
        choice=$(printf "Launch\nCreate\nRemove" | dmenu -i -p "Web Apps:")
        case "$choice" in Create) create ;; Remove) remove ;; Launch) launch ;; esac
        ;;
esac
