#!/bin/sh
# Web app manager with Chromium profile support

set -e

ICONS="$HOME/.local/share/applications/icons"
APPS="$HOME/.local/share/applications"
BROWSER="chromium"
CHROME_CONFIG="$HOME/.config/chromium"

mkdir -p "$ICONS" "$APPS"

get_apps() { grep -l "^Exec=.*--app=" "$APPS"/*.desktop 2>/dev/null | while read f; do grep '^Name=' "$f" | cut -d= -f2-; done | sort; }

get_profiles() {
    [ -d "$CHROME_CONFIG" ] || return
    # Default profile
    [ -d "$CHROME_CONFIG/Default" ] && echo "Default:Default"
    # Additional profiles (Profile 1, Profile 2, etc.)
    for d in "$CHROME_CONFIG"/Profile\ *; do
        [ -d "$d" ] || continue
        dir=$(basename "$d")
        name=$(grep -o '"name":"[^"]*"' "$d/Preferences" 2>/dev/null | head -1 | cut -d'"' -f4)
        [ -n "$name" ] && echo "${name}:${dir}" || echo "${dir}:${dir}"
    done
}

validate_profile() { [ -d "$CHROME_CONFIG/$1" ] && echo "$1" || echo "Default"; }

create() {
    profiles=$(get_profiles)
    profile="Default"
    [ "$(echo "$profiles" | wc -l)" -gt 1 ] && {
        sel=$(echo "$profiles" | cut -d: -f1 | dmenu -i -p "Profile:")
        [ -n "$sel" ] && profile=$(echo "$profiles" | grep "^$sel:" | cut -d: -f2)
    }
    profile=$(validate_profile "$profile")

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
Exec=$BROWSER --profile-directory="$profile" --app="$url" --class="$safe"
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
    cmd=$(grep '^Exec=' "$file" | cut -d= -f2-)
    eval "$cmd" &
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
