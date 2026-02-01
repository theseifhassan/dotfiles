#!/bin/sh
set -e
# dmenu-based audio device switcher
# Quickly switch between sinks (outputs) and sources (inputs)

# Get sinks (outputs) - format: "ID. Name [vol]" where * marks default
get_sinks() {
    wpctl status | awk '
        /^Audio/,/^Video/ {
            if (/Sinks:/) { in_sinks=1; next }
            if (/Sink endpoints:/ || /Sources:/ || /^[A-Z]/) { in_sinks=0 }
            if (in_sinks && /│/) {
                gsub(/[│├└─]/, "")
                gsub(/^[ \t]+|[ \t]+$/, "")
                if (length > 0) print
            }
        }
    '
}

# Get sources (inputs) - format: "ID. Name [vol]" where * marks default
get_sources() {
    wpctl status | awk '
        /^Audio/,/^Video/ {
            if (/Sources:/) { in_sources=1; next }
            if (/Source endpoints:/ || /Filters:/ || /^[A-Z]/) { in_sources=0 }
            if (in_sources && /│/) {
                gsub(/[│├└─]/, "")
                gsub(/^[ \t]+|[ \t]+$/, "")
                if (length > 0) print
            }
        }
    '
}

# Extract ID from selection (handles "ID. Name" or "* ID. Name" format)
get_id() {
    echo "$1" | sed 's/^\* //' | cut -d. -f1 | tr -cd '0-9'
}

# Main menu
main_menu() {
    choice=$(printf "Output (Sinks)\nInput (Sources)" | dmenu -i -p "Audio:")
    case "$choice" in
        "Output (Sinks)") select_sink ;;
        "Input (Sources)") select_source ;;
    esac
}

select_sink() {
    sinks=$(get_sinks)
    [ -z "$sinks" ] && { notify-send "Audio" "No sinks found"; exit 1; }

    sel=$(echo "$sinks" | dmenu -i -l 10 -p "Output:")
    [ -z "$sel" ] && exit 0

    id=$(get_id "$sel")
    [ -z "$id" ] && { notify-send "Audio" "Could not parse device ID"; exit 1; }

    wpctl set-default "$id"
    name=$(echo "$sel" | sed 's/^\* //; s/^[0-9]*\. //')
    notify-send "Audio Output" "$name"
}

select_source() {
    sources=$(get_sources)
    [ -z "$sources" ] && { notify-send "Audio" "No sources found"; exit 1; }

    sel=$(echo "$sources" | dmenu -i -l 10 -p "Input:")
    [ -z "$sel" ] && exit 0

    id=$(get_id "$sel")
    [ -z "$id" ] && { notify-send "Audio" "Could not parse device ID"; exit 1; }

    wpctl set-default "$id"
    name=$(echo "$sel" | sed 's/^\* //; s/^[0-9]*\. //')
    notify-send "Audio Input" "$name"
}

[ "${SOURCED:-}" = "1" ] && return 0 2>/dev/null || true

command -v wpctl >/dev/null || { echo "wpctl required (wireplumber)"; exit 1; }
command -v dmenu >/dev/null || { echo "dmenu required"; exit 1; }

# Allow direct sink/source selection via argument
case "${1:-}" in
    sink|output) select_sink ;;
    source|input) select_source ;;
    *) main_menu ;;
esac
