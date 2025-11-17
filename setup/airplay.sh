#!/bin/sh
# pw-raop - Configure PipeWire RAOP module for AirPlay streaming
# Dependencies: pipewire, avahi
# No bashisms, no unnecessary features, does one thing well

# Exit on any error
set -e

# Configuration
PIPEWIRE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
RAOP_CONFIG_FILE="$PIPEWIRE_CONFIG_DIR/raop.conf"

# Simple logging - no colors, no unicode, just text
log() { printf '%s\n' "$1"; }
die() { printf 'error: %s\n' "$1" >&2; exit 1; }

# Check if running as root (we shouldn't be)
[ "$(id -u)" -eq 0 ] && die "do not run as root"

# Verify dependencies
check_deps() {
    for cmd in pipewire avahi-daemon pactl pw-cli; do
        command -v "$cmd" >/dev/null 2>&1 || die "$cmd not found"
    done
}

# Enable mDNS in NSS - required for .local resolution
configure_nss() {
    if ! grep -q "mdns_minimal" /etc/nsswitch.conf; then
        log "configuring nss for mDNS (requires sudo)"
        sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files dns/' /etc/nsswitch.conf
    fi
}

# Start Avahi daemon
start_avahi() {
    if ! systemctl is-active --quiet avahi-daemon; then
        log "starting avahi-daemon"
        sudo systemctl enable --now avahi-daemon.service
    fi
}

# Create minimal RAOP configuration
create_config() {
    # Create directory if needed
    [ ! -d "$PIPEWIRE_CONFIG_DIR" ] && mkdir -p "$PIPEWIRE_CONFIG_DIR"
    
    # Write minimal config - no fancy options, just load the module
    cat > "$RAOP_CONFIG_FILE" << 'EOF'
# RAOP discovery module for AirPlay devices
context.modules = [
    { name = libpipewire-module-raop-discover }
]
EOF
    
    log "created $RAOP_CONFIG_FILE"
}

# Restart PipeWire to load configuration
restart_pipewire() {
    log "restarting pipewire"
    systemctl --user restart pipewire.service
    systemctl --user restart pipewire-pulse.service
    
    # Wait for services to stabilize
    sleep 2
}

# List discovered AirPlay devices
list_devices() {
    log "waiting for device discovery..."
    sleep 5
    
    log "available raop sinks:"
    pactl list short sinks | grep raop || log "no devices found yet"
}

# Set HomePod as default sink
set_default() {
    # Get first RAOP sink
    sink=$(pactl list short sinks | grep raop | head -1 | cut -f2)
    
    if [ -n "$sink" ]; then
        pactl set-default-sink "$sink"
        log "set default sink: $sink"
    else
        log "no raop sink available to set as default"
    fi
}

# Cleanup function
cleanup() {
    if [ -f "$RAOP_CONFIG_FILE" ]; then
        rm "$RAOP_CONFIG_FILE"
        log "removed $RAOP_CONFIG_FILE"
        restart_pipewire
    fi
}

# Main
main() {
    case "${1:-setup}" in
        setup)
            check_deps
            configure_nss
            start_avahi
            create_config
            restart_pipewire
            list_devices
            ;;
        list)
            list_devices
            ;;
        set-default)
            set_default
            ;;
        cleanup)
            cleanup
            ;;
        *)
            cat << EOF
usage: $(basename "$0") [setup|list|set-default|cleanup]

commands:
    setup       - configure system for RAOP streaming (default)
    list        - list available AirPlay devices
    set-default - set first RAOP device as default sink
    cleanup     - remove configuration and restart pipewire

This script configures PipeWire to stream audio to AirPlay devices.
It follows suckless principles: minimal, clear, no bloat.
EOF
            exit 0
            ;;
    esac
}

main "$@"
