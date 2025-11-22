#!/bin/bash

# ------------------------------------------------------------------------------
# Bootstrap Script
# ------------------------------------------------------------------------------
# Prepares the system for package installation.
# - Installs base-devel and git
# - Installs 'yay' AUR helper (required for subsequent scripts)
# ------------------------------------------------------------------------------

set -e

echo ">> Bootstrapping..."

# Install base-devel and git if missing
if ! pacman -Qi base-devel &>/dev/null || ! pacman -Qi git &>/dev/null; then
    echo "Installing base-devel and git..."
    sudo pacman -S --needed --noconfirm base-devel git
fi

# Install yay if missing
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -si --noconfirm
    popd
    rm -rf /tmp/yay
else
    echo "yay is already installed."
fi
