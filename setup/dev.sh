#!/bin/bash

# ------------------------------------------------------------------------------
# Development Environment Setup
# ------------------------------------------------------------------------------
# Sets up the coding environment.
# - Installs Node.js using 'tj/n' (in ~/.local/share/n) to avoid root requirement.
# - Installs LSP servers for Neovim/Helix/Zed via pacman and npm.
# ------------------------------------------------------------------------------

set -e

echo ">> Setting up Development Environment (Node.js & LSPs)..."

# ------------------------------------------------------------------------------
# Node.js (tj/n)
# ------------------------------------------------------------------------------
echo ">> Setting up Node.js environment via tj/n..."

# Set up N_PREFIX to avoid sudo/root usage
export N_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/n"
export PATH="$N_PREFIX/bin:$PATH"

# Create the directory structure explicitly
mkdir -p "$N_PREFIX/bin" "$N_PREFIX/lib" "$N_PREFIX/include" "$N_PREFIX/share"

# Check if n is installed
if ! command -v n &>/dev/null; then
    echo "Warning: 'n' was not found in PATH. It should have been installed via packaging.sh."
    echo "Attempting fallback installation via curl..."
    curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n-script
    chmod +x /tmp/n-script
    echo "Installing Node.js LTS using n script..."
    export N_PREFIX="$N_PREFIX"
    /tmp/n-script lts
else
    echo "Installing/Updating Node.js LTS..."
    n lts
fi

# Verify Node
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# ------------------------------------------------------------------------------
# LSP Servers
# ------------------------------------------------------------------------------
echo ">> Installing LSP servers..."

# Check if npm is available (it should be now)
if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm not found even after Node setup."
    exit 1
fi

# Install from official repositories (pacman)
echo "Installing LSP servers from official repositories..."
# Check if packages are already installed to save time, but yay handles this efficiently
# We'll rely on yay or pacman
if command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm \
        typescript-language-server \
        lua-language-server \
        marksman \
        yaml-language-server \
        ccls \
        bash-language-server
else
    sudo pacman -S --needed --noconfirm \
        typescript-language-server \
        lua-language-server \
        marksman \
        yaml-language-server \
        ccls \
        bash-language-server
fi

# Install from npm
echo "Installing LSP servers from npm..."
npm install -g \
    @tailwindcss/language-server \
    @biomejs/biome

echo "Development Environment Setup Complete."
