#!/bin/sh
# LSP Server Installation Script for Arch Linux
# Installs language servers for Neovim/IDE development

set -e

echo "Installing LSP servers..."

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm not found. Please install Node.js first."
    echo "Run: sudo pacman -S nodejs npm"
    exit 1
fi

# Install from official repositories
echo "Installing LSP servers from official repositories..."
sudo pacman -S --needed --noconfirm \
    typescript-language-server \
    lua-language-server \
    marksman \
    yaml-language-server \
    ccls \
    bash-language-server

# Install from npm
echo "Installing LSP servers from npm..."
npm install -g \
    @tailwindcss/language-server \
    @biomejs/biome

printf "\nLSP servers installed successfully!\n"
printf "Configure these in your Neovim LSP setup.\n"
