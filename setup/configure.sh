#!/bin/bash

# ------------------------------------------------------------------------------
# System Configuration Script
# ------------------------------------------------------------------------------
# Configures various system services and preferences.
# - Docker: Enables service, adds user to group.
# - GnuPG: Sets up XDG-compliant paths.
# - Fonts: Refreshes font cache.
# - MPD: Creates directories and enables user services.
# - Streaming: Configures v4l2loopback (OBS Virtual Cam) and usbmuxd.
# - Theme: Enforces GTK Dark Mode.
# ------------------------------------------------------------------------------

set -e

echo ">> Starting System Configuration..."

# ------------------------------------------------------------------------------
# Docker Configuration
# ------------------------------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
    echo "Configuring Docker..."
    # Enable and start Docker service
    sudo systemctl enable --now docker || echo "Warning: Failed to enable Docker service"

    # Add user to docker group (grants root-equivalent access)
    if ! groups "$USER" | grep -q docker; then
        echo "Adding user to docker group..."
        sudo usermod -aG docker "${USER}" || echo "Warning: Failed to add user to docker group"
    fi
else
    echo "Docker not found. Skipping configuration."
fi

# ------------------------------------------------------------------------------
# GnuPG Configuration (XDG Support)
# ------------------------------------------------------------------------------
echo "Configuring GnuPG..."
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Create systemd drop-in directory and override file
mkdir -p ~/.config/systemd/user/gpg-agent.service.d/
cat > ~/.config/systemd/user/gpg-agent.service.d/override.conf << EOF
[Service]
Environment="GNUPGHOME=%h/.local/share/gnupg"
EOF

# Create new GPG directory
mkdir -p "$XDG_DATA_HOME/gnupg"
chmod 700 "$XDG_DATA_HOME/gnupg"

# Migrate existing GPG data if it exists and has content
if [ -d ~/.gnupg ] && [ -n "$(ls -A ~/.gnupg 2>/dev/null)" ]; then
    echo "Migrating existing GPG data..."
    cp -r ~/.gnupg/* "$XDG_DATA_HOME/gnupg/" || echo "Warning: GPG migration failed"
    chmod 700 "$XDG_DATA_HOME/gnupg"
    find "$XDG_DATA_HOME/gnupg" -type f -exec chmod 600 {} \;
fi

# Reload systemd and restart GPG agent
systemctl --user daemon-reload
gpgconf --kill gpg-agent 2>/dev/null || true

# ------------------------------------------------------------------------------
# Fonts Configuration
# ------------------------------------------------------------------------------
echo "Configuring Fonts..."
# Create font directories
mkdir -p ~/.local/share/fonts ~/.config/fontconfig/conf.d

# Rebuild font cache
echo "Rebuilding font cache..."
fc-cache -f

# ------------------------------------------------------------------------------
# MPD Configuration
# ------------------------------------------------------------------------------
echo "Configuring MPD..."
# Create XDG-compliant directories
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/mpd"
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/mpd"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/mpd"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/mpd"

# Enable and start services
if command -v mpd >/dev/null 2>&1; then
    systemctl --user enable --now mpd.service || echo "Warning: Failed to enable MPD"
    systemctl --user enable --now mpd-mpris.service || echo "Warning: Failed to enable MPD-MPRIS"
fi

# ------------------------------------------------------------------------------
# Streaming Configuration (OBS/Virtual Cam)
# ------------------------------------------------------------------------------
echo "Configuring Streaming..."

# Enable usbmuxd service
if command -v usbmuxd >/dev/null 2>&1; then
    sudo systemctl enable --now usbmuxd || echo "Warning: Failed to enable usbmuxd"
fi

# Configure v4l2loopback
if ls /usr/lib/modules/*/extramodules/v4l2loopback.ko.zst >/dev/null 2>&1 || ls /lib/modules/*/updates/dkms/v4l2loopback.ko.zst >/dev/null 2>&1; then
    echo "Configuring v4l2loopback..."
    echo 'options v4l2loopback devices=1 video_nr=0 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null
    echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    
    # Load module now
    if ! lsmod | grep -q v4l2loopback; then
        sudo modprobe v4l2loopback || echo "Warning: Failed to load v4l2loopback module."
    fi
fi

# ------------------------------------------------------------------------------
# Theme Configuration
# ------------------------------------------------------------------------------
echo "Configuring Theme..."
if command -v gsettings >/dev/null 2>&1; then
    # Desktop interface
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    echo "Theme set to dark."
fi

echo "System Configuration Complete."
