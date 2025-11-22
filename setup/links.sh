#!/bin/bash

# ------------------------------------------------------------------------------
# Dotfiles Linking Script
# ------------------------------------------------------------------------------
# Symlinks configuration files to their standard locations.
# - X11 (.xinitrc)
# - ZSH (.zshrc)
# - App Configs (nvim, tmux, ghostty, zed) -> ~/.config/
# - Scripts -> ~/.local/bin/
# ------------------------------------------------------------------------------

set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

echo ">> Linking configurations..."

create_link() {
    local src=$1
    local dest=$2
    
    mkdir -p "$(dirname "$dest")"
    
    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
             # It's already a link, update it
             rm "$dest"
        else
             echo "Backing up existing $dest to ${dest}.bak"
             mv "$dest" "${dest}.bak"
        fi
    fi
    
    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
}

# X11
create_link "$DOTFILES/x11/.config/x11/xinitrc" "$HOME/.xinitrc"

# ZSH
create_link "$DOTFILES/zsh/.config/zsh/.zshrc" "$HOME/.zshrc"
# Link .zshenv if it exists
if [ -f "$DOTFILES/zsh/.zshenv" ]; then
    create_link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
fi

# Neovim
create_link "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"

# Tmux
create_link "$DOTFILES/tmux/.config/tmux" "$HOME/.config/tmux"

# Ghostty
create_link "$DOTFILES/ghostty/.config/ghostty" "$HOME/.config/ghostty"

# Zed
create_link "$DOTFILES/zed/.config/zed" "$HOME/.config/zed"

# Scripts
# Instead of linking individual scripts, we link the bin directory or individual files
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES/scripts/.local/bin/"*; do
    filename=$(basename "$script")
    create_link "$script" "$HOME/.local/bin/$filename"
done

echo "Configuration linking complete."
