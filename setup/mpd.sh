#!/bin/sh
# MPD (Music Player Daemon) Setup Script for Arch Linux
# Installs: mpd, mpd-mpris, rmpc, playerctl
# Note: Config managed by stow

set -e

echo "Setting up MPD..."

# Install packages
echo "Installing packages..."
sudo pacman -S --needed --noconfirm mpd mpd-mpris rmpc playerctl

# Create XDG-compliant directories
echo "Creating MPD directories..."
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/mpd"
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/mpd"
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/mpd"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/mpd"

# Enable and start services
echo "Enabling and starting MPD services..."
systemctl --user enable --now mpd.service
systemctl --user enable --now mpd-mpris.service

printf "\nMPD setup complete!\n"
printf "Check status: systemctl --user status mpd\n"
printf "Control with: rmpc\n"
