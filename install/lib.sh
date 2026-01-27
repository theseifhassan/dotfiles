#!/bin/sh
# Shared functions for dotfiles scripts

# Create symlink, backing up existing file if needed
# Usage: link <source> <target>
link() {
    mkdir -p "$(dirname "$2")"
    [ -L "$2" ] && rm "$2"
    [ -e "$2" ] && mv "$2" "$2.bak"
    ln -s "$1" "$2"
}

# Log with prefix
log() { echo ">>> $1"; }
