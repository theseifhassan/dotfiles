#!/bin/sh
# Font Installation Script for Arch Linux
# Installs essential fonts: Noto family and Nerd Fonts symbols

set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Don't run this script as root. Run as your regular user."
    exit 1
fi

echo "Installing fonts..."

# Install from official repositories
echo "Installing fonts from official repositories..."
sudo pacman -S --needed --noconfirm \
    noto-fonts \
    noto-fonts-extra \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols

# Create font directories
echo "Creating font directories..."
mkdir -p ~/.local/share/fonts ~/.config/fontconfig/conf.d

# Rebuild font cache
echo "Rebuilding font cache..."
fc-cache -f

printf "\nFont installation complete!\n"
printf "Place custom fonts in: ~/.local/share/fonts\n"
printf "Then run: fc-cache -f ~/.local/share/fonts\n"
