#!/bin/sh
# Docker Installation and Configuration Script
# Installs Docker and adds user to docker group

if [ "$(id -u)" -eq 0 ]; then
    echo "Don't run this script as root. Run as your regular user."
    exit 1
fi

echo "Setting up Docker..."

# Install Docker
sudo pacman -S --needed --noconfirm docker

# Enable and start Docker service
sudo systemctl enable --now docker

# Add user to docker group (grants root-equivalent access)
echo "WARNING: Adding user to docker group grants root-equivalent access"
sudo usermod -aG docker "${USER}"

echo ""
echo "Docker installed successfully!"
echo "Log out and back in to use Docker without sudo."
