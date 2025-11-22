#!/bin/bash
# ------------------------------------------------------------------------------
# Master Installation Script
# ------------------------------------------------------------------------------
# Orchestrates the entire Arch Linux setup process.
# 1. Bootstraps AUR helper (yay)
# 2. Installs packages (Official & AUR)
# 3. Sets up Hardware (Nvidia), Development (Node/LSP), and System Configs
# 4. Compiles Suckless tools (dwm, dmenu)
# 5. Links Dotfiles
# 6. Sets Shell
# ------------------------------------------------------------------------------
set -e

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">> Starting Opencode Arch Setup..."

# 1. Bootstrap (AUR helper)
source "$DOTFILES/setup/bootstrap.sh"

# 2. Packages (Installs base tools + dependencies)
source "$DOTFILES/setup/packaging.sh"

# 3. Nvidia (Hardware Specific - Separate)
if [ -f "$DOTFILES/setup/nvidia.sh" ]; then
    echo "Running nvidia.sh..."
    bash "$DOTFILES/setup/nvidia.sh"
fi

# 4. Development Environment (Node + LSPs)
if [ -f "$DOTFILES/setup/dev.sh" ]; then
    echo "Running dev.sh..."
    bash "$DOTFILES/setup/dev.sh"
    
    # Export Node environment for this session
    export N_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/n"
    export PATH="$N_PREFIX/bin:$PATH"
fi

# 5. System Configuration (Services, Fonts, Theme, etc.)
if [ -f "$DOTFILES/setup/configure.sh" ]; then
    echo "Running configure.sh..."
    bash "$DOTFILES/setup/configure.sh"
fi

# 6. Suckless Compilation (Custom Builds)
source "$DOTFILES/setup/suckless.sh"

# 7. Opencode Agent
echo ">> Installing Opencode..."
curl -fsSL https://opencode.ai/install | bash

# 8. Config Linking
source "$DOTFILES/setup/links.sh"

# 9. Shell Setup
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    sudo chsh -s /usr/bin/zsh "$USER"
fi

echo "------------------------------------------------"
echo "Installation complete!"
echo "Please restart your session or reboot to apply all changes."
