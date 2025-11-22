#!/bin/bash

# ------------------------------------------------------------------------------
# Package Installation Script
# ------------------------------------------------------------------------------
# Installs all software defined in 'packages.list'.
# - Uses 'yay' to handle both official Arch packages and AUR packages transparently.
# - Skips comments and empty lines in the list.
# ------------------------------------------------------------------------------

set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PACKAGES_LIST="$DOTFILES/packages.list"

echo ">> Installing packages from $PACKAGES_LIST..."

if [ ! -f "$PACKAGES_LIST" ]; then
    echo "Error: packages.list not found at $PACKAGES_LIST"
    exit 1
fi

# Filter out comments and empty lines
PACKAGES=$(grep -vE "^\s*#" "$PACKAGES_LIST" | tr '\n' ' ')

if [ -n "$PACKAGES" ]; then
    yay -S --needed --noconfirm $PACKAGES
else
    echo "No packages to install."
fi
