#!/bin/sh
# Shared functions for dotfiles scripts

# Create symlink, backing up existing file if needed
# Usage: link <source> <target>
link() {
    mkdir -p "$(dirname "$2")"
    # Skip if already correct symlink
    [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ] && return 0
    [ -L "$2" ] && rm "$2"
    [ -e "$2" ] && mv "$2" "$2.bak"
    ln -s "$1" "$2"
}

# Log with prefix
log() { echo ">>> $1"; }

# Link all config files — single source of truth for symlink operations
# Requires: $DOTFILES set, link() available
link_configs() {
    link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
    link "$DOTFILES/zsh/.config/zsh" "$HOME/.config/zsh"
    link "$DOTFILES/x11/.config/x11" "$HOME/.config/x11"
    link "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"
    link "$DOTFILES/tmux/.config/tmux" "$HOME/.config/tmux"
    link "$DOTFILES/ghostty/.config/ghostty" "$HOME/.config/ghostty"
    link "$DOTFILES/picom/.config/picom" "$HOME/.config/picom"
    link "$DOTFILES/dunst/.config/dunst" "$HOME/.config/dunst"
    link "$DOTFILES/git/.config/git" "$HOME/.config/git"
    link "$DOTFILES/ripgrep/.config/ripgrep" "$HOME/.config/ripgrep"
    link "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"
    link "$DOTFILES/opencode/.config/opencode" "$HOME/.config/opencode"
    link "$DOTFILES/autorandr/.config/autorandr" "$HOME/.config/autorandr"
    link "$DOTFILES/fontconfig/.config/fontconfig" "$HOME/.config/fontconfig"
    link "$DOTFILES/npm/.config/npm" "$HOME/.config/npm"
    link "$DOTFILES/mise/.config/mise" "$HOME/.config/mise"

    # SSH and 1Password (ensure directories exist with correct permissions)
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    link "$DOTFILES/ssh/.ssh/config" "$HOME/.ssh/config"
    mkdir -p "$HOME/.config/1Password/ssh"
    link "$DOTFILES/1password/.config/1Password/ssh/agent.toml" "$HOME/.config/1Password/ssh/agent.toml"

    # Link wallpapers if present
    if [ -d "$DOTFILES/wallpapers" ] && find "$DOTFILES/wallpapers" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | grep -q .; then
        mkdir -p "$HOME/Pictures"
        link "$DOTFILES/wallpapers" "$HOME/Pictures/Wallpapers"
    fi

    mkdir -p "$HOME/.local/bin"
    for f in "$DOTFILES/scripts/.local/bin/"*; do link "$f" "$HOME/.local/bin/$(basename "$f")"; done

    # Link web apps
    mkdir -p "$HOME/.local/share/applications"
    for f in "$DOTFILES/applications/.local/share/applications/"*.desktop; do
        [ -f "$f" ] && link "$f" "$HOME/.local/share/applications/$(basename "$f")"
    done

    mkdir -p "$HOME/.config/systemd/user"
    for f in "$DOTFILES/scripts/.config/systemd/user/"*; do link "$f" "$HOME/.config/systemd/user/$(basename "$f")"; done
}
