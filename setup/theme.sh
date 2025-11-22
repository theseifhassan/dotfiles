#!/bin/sh
# XDG Desktop Portal Theme Switching Setup
# Installs portal + GTK backend, verifies D-Bus activation, enables live theme switching

set -e

# Must run as user (portals are per-user D-Bus services)
[ "$(id -u)" -eq 0 ] && { printf "Run as user, not root.\n" >&2; exit 1; }

# Installation
install_portals() {
    printf "Installing xdg-desktop-portal...\n"
    
    # Check if already installed (idempotent)
    if pacman -Qi xdg-desktop-portal xdg-desktop-portal-gtk glib2 >/dev/null 2>&1; then
        printf "Already installed.\n"
        return 0
    fi
    
    sudo pacman -S --needed --noconfirm xdg-desktop-portal xdg-desktop-portal-gtk glib2
}

# Verify portal responds via D-Bus (triggers auto-start)
verify_portal() {
    printf "Verifying portal via D-Bus...\n"
    
    # Check D-Bus session bus exists
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        printf "WARNING: No D-Bus session bus. Portal may not work.\n" >&2
        printf "Add 'dbus-launch' to ~/.xinitrc or install dbus-x11.\n" >&2
        return 1
    fi
    
    # Query portal API (forces D-Bus activation + confirms functional)
    if ! busctl --user call \
        org.freedesktop.portal.Desktop \
        /org/freedesktop/portal/desktop \
        org.freedesktop.portal.Settings Read \
        ss "org.freedesktop.appearance" "color-scheme" >/dev/null 2>&1; then
        printf "ERROR: Portal not responding. Check D-Bus daemon running.\n" >&2
        return 1
    fi
    
    printf "Portal working.\n"
}

# Set default theme preference
set_default_theme() {
    printf "Setting default theme to dark...\n"
    
    # Verify gsettings available
    if ! command -v gsettings >/dev/null 2>&1; then
        printf "ERROR: gsettings not found. Install glib2.\n" >&2
        return 1
    fi
    
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    
    # Verify setting applied
    current=$(gsettings get org.gnome.desktop.interface color-scheme)
    printf "Current theme: %s\n" "$current"
}

# Main execution
install_portals
verify_portal
set_default_theme
