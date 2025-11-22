#!/bin/bash

# ------------------------------------------------------------------------------
# Suckless Compilation Script
# ------------------------------------------------------------------------------
# Compiles and installs custom Window Manager tools.
# - Targets: dwm, dmenu, dwmblocks.
# - Runs 'make clean install' in each directory.
# ------------------------------------------------------------------------------

set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

echo ">> Compiling and installing suckless tools..."

# List of suckless tools to compile
TOOLS=("dwm" "dmenu" "dwmblocks")

for tool in "${TOOLS[@]}"; do
    echo "Building $tool..."
    if [ -d "$DOTFILES/$tool" ]; then
        pushd "$DOTFILES/$tool"
        sudo make clean install
        popd
    else
        echo "Warning: Directory $DOTFILES/$tool does not exist. Skipping."
    fi
done
