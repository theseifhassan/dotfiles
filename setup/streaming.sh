#!/bin/sh
# Streaming Setup Script for Arch Linux
# Installs: obs-studio, usbmuxd, v4l2loopback-dkms, droidcam-obs-plugin

echo "Setting up streaming environment..."

# Check for AUR helper
if ! command -v paru >/dev/null 2>&1; then
    echo "Error: paru not found. Install yay or paru first."
    exit 1
fi

# Install packages
sudo pacman -S --needed --noconfirm obs-studio usbmuxd v4l2loopback-dkms
paru -S --needed --noconfirm droidcam-obs-plugin

# Enable usbmuxd service
sudo systemctl enable --now usbmuxd

# Configure v4l2loopback
echo 'options v4l2loopback devices=1 video_nr=0 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf

# Load v4l2loopback on boot
echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf

# Load v4l2loopback module now
sudo modprobe v4l2loopback

echo "Streaming setup complete!"
echo "Reboot or run 'sudo modprobe v4l2loopback' to activate virtual camera"
echo "Virtual camera available at /dev/video0"
