#!/bin/bash

# Web App Manager - Simple dmenu-only web application manager
# Creates web apps that launch in chromium --app mode

set -euo pipefail

ICON_DIR="$HOME/.local/share/applications/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
BROWSER="chromium"

mkdir -p "$ICON_DIR" "$DESKTOP_DIR"

# Check dmenu is available
command -v dmenu >/dev/null 2>&1 || {
    echo "Error: dmenu is required" >&2
    exit 1
}

get_webapp_list() {
    find "$DESKTOP_DIR" -name '*.desktop' -print0 2>/dev/null | while IFS= read -r -d '' file; do
        if [[ -f "$file" ]] && grep -q "^Exec=.*--app=" "$file" 2>/dev/null; then
            grep '^Name=' "$file" | cut -d'=' -f2- | head -1
        fi
    done | sort
}

create_webapp() {
    local input
    input=$(echo "" | dmenu -i -p "app_name|app_url|icon_url")
    [[ -z "$input" ]] && exit 0
    
    IFS='|' read -r app_name app_url icon_url <<< "$input"
    
    [[ -z "$app_name" || -z "$app_url" || -z "$icon_url" ]] && {
        echo "All fields required" | dmenu -i -b -p "Error:"
        exit 1
    }
    
    [[ $app_url =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]] || {
        echo "Invalid URL format" | dmenu -i -b -p "Error:"
        exit 1
    }
    
    local safe_name
    safe_name=$(echo "$app_name" | sed 's/[^a-zA-Z0-9._-]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
    local desktop_file="$DESKTOP_DIR/${safe_name}.desktop"
    local icon_path="$ICON_DIR/${safe_name}.${icon_url##*.}"
    icon_path="${icon_path%%\?*}"
    
    [[ -f "$desktop_file" ]] && {
        echo "App already exists" | dmenu -i -p "Error:"
        exit 1
    }
    
    curl -sL --max-time 30 -o "$icon_path" "$icon_url" || {
        echo "Failed to download icon" | dmenu -i -p "Error:"
        exit 1
    }
    
    [[ -s "$icon_path" ]] || {
        rm -f "$icon_path"
        echo "Icon download failed" | dmenu -i -p "Error:"
        exit 1
    }
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=Web application: $app_name
Exec=$BROWSER --app="$app_url" --class="$safe_name"
Terminal=false
Type=Application
Icon=$icon_path
StartupNotify=true
Categories=Network;WebBrowser;
MimeType=x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=$safe_name
EOF
    
    chmod 644 "$desktop_file"
    command -v notify-send >/dev/null 2>&1 && notify-send --icon=blank "Web App Manager" "Created: $app_name"
}

remove_webapp() {
    local apps
    apps=$(get_webapp_list)
    [[ -z "$apps" ]] && exit 0
    
    local selected
    selected=$(echo "$apps" | dmenu -i -p "Remove app:")
    [[ -z "$selected" ]] && exit 0
    
    local confirm
    confirm=$(echo -e "Yes\nNo" | dmenu -i -p "Remove '$selected'?")
    [[ "$confirm" != "Yes" ]] && exit 0
    
    local desktop_file="" icon_path=""
    
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]] && grep -q "^Exec=.*--app=" "$file" 2>/dev/null; then
            local found_name
            found_name=$(grep '^Name=' "$file" | cut -d'=' -f2- | head -1)
            if [[ "$found_name" == "$selected" ]]; then
                desktop_file="$file"
                icon_path=$(grep '^Icon=' "$file" | cut -d'=' -f2- 2>/dev/null || true)
                break
            fi
        fi
    done < <(find "$DESKTOP_DIR" -name '*.desktop' -print0 2>/dev/null)
    
    rm -f "$desktop_file"
    [[ -n "$icon_path" && -f "$icon_path" ]] && rm -f "$icon_path"
    
    command -v notify-send >/dev/null 2>&1 && notify-send --icon=blank "Web App Manager" "Removed: $selected"
}

launch_webapp() {
    local apps
    apps=$(get_webapp_list)
    [[ -z "$apps" ]] && exit 0

    local selected
    selected=$(echo "$apps" | dmenu -i -p "Launch app:")
    [[ -z "$selected" ]] && exit 0

    # Find desktop file by matching Name field
    local desktop_file=""
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]] && grep -q "^Exec=.*--app=" "$file" 2>/dev/null; then
            local found_name
            found_name=$(grep '^Name=' "$file" | cut -d'=' -f2- | head -1)
            if [[ "$found_name" == "$selected" ]]; then
                desktop_file="$file"
                break
            fi
        fi
    done < <(find "$DESKTOP_DIR" -name '*.desktop' -print0 2>/dev/null)
    
    [[ -n "$desktop_file" ]] && dex "$desktop_file" &
}

# Main execution
case "${1:-}" in
    "create"|"add")
        create_webapp
        ;;
    "remove"|"rm")
        remove_webapp
        ;;
    "launch"|"run")
        launch_webapp
        ;;
        "")
        # Main menu
        choice=$(echo -e "Create\nRemove\nLaunch" | dmenu -i -p "Web App Manager:")
        case "$choice" in
            "Create") create_webapp ;;
            "Remove") remove_webapp ;;
            "Launch") launch_webapp ;;
        esac
        ;;
esac
