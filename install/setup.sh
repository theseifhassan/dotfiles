#!/bin/sh
set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export DOTFILES

# shellcheck source=lib.sh
. "$DOTFILES/install/lib.sh"

# Cache sudo credentials upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Bootstrap
log "Bootstrap"
command -v paru >/dev/null || {
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    rm -rf /tmp/paru
}

# Packages
log "Packages"
sudo pacman -Syu --noconfirm
paru -S --needed --noconfirm $(grep -vE "^\s*#|^\s*$" "$DOTFILES/install/packages" | tr '\n' ' ')

# Configure
log "Configure"
command -v docker >/dev/null && {
    sudo systemctl enable --now docker
    groups "$USER" | grep -q docker || sudo usermod -aG docker "$USER"
}
command -v tailscale >/dev/null && sudo systemctl enable --now tailscaled
command -v powerprofilesctl >/dev/null && {
    sudo systemctl enable --now power-profiles-daemon
    # Default to performance on desktops (no battery)
    [ ! -d /sys/class/power_supply/BAT0 ] && powerprofilesctl set performance
}
command -v autorandr >/dev/null && sudo systemctl enable autorandr.service 2>/dev/null || true
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg" && chmod 700 "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
mkdir -p ~/.local/share/fonts && fc-cache -f
command -v gsettings >/dev/null && {
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
}

# User directories
log "User directories"
xdg-user-dirs-update
mkdir -p "$HOME/Projects"

# Touchpad
log "Touchpad"
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp "$DOTFILES/x11/30-touchpad.conf" /etc/X11/xorg.conf.d/



# Hardware
log "Hardware"
# Disable NVIDIA GPU by default for maximum battery life
# Use 'dot hardware nvidia' to enable when needed
if lspci | grep -qi nvidia && command -v envycontrol >/dev/null; then
    log "Disabling NVIDIA GPU (use 'dot hardware nvidia' to enable)"
    sudo envycontrol -s integrated --no-confirm || true
fi
"$DOTFILES/install/hardware.sh" bluetooth

# Suckless
log "Suckless"
for t in dwm dmenu dwmblocks; do [ -d "$DOTFILES/$t" ] && sudo make -C "$DOTFILES/$t" clean install; done

# Links
log "Links"

# Copy defaults to XDG_DATA_HOME
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
cp -r "$DOTFILES/default" "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"

# Install fonts if present
if [ -d "$DOTFILES/fonts" ] && [ "$(ls -A "$DOTFILES/fonts" 2>/dev/null | grep -v .keep)" ]; then
    log "Installing fonts..."
    mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    cp -r "$DOTFILES/fonts/"* "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/" 2>/dev/null || true
    fc-cache -f
fi

# Install TPM
TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"
[ ! -d "$TPM_DIR" ] && git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

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
if [ -d "$DOTFILES/wallpapers" ] && [ "$(ls -A "$DOTFILES/wallpapers" 2>/dev/null | grep -v .keep)" ]; then
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

# Enable wallpaper timer
systemctl --user daemon-reload
systemctl --user enable --now wallpaper.timer 2>/dev/null || true

# OpenCode
log "OpenCode"
command -v opencode >/dev/null || curl -fsSL https://opencode.ai/install | bash

# Shell
log "Shell"
[ "$SHELL" != "$(command -v zsh)" ] && chsh -s "$(command -v zsh)"

log "Done! Reboot to apply."
