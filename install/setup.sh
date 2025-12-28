#!/bin/sh
set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export DOTFILES

log() { echo ">>> $1"; }

# Bootstrap
log "Bootstrap"
command -v yay >/dev/null || {
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    rm -rf /tmp/yay
}

# Packages
log "Packages"
yay -S --needed --noconfirm $(grep -vE "^\s*#|^\s*$" "$DOTFILES/install/packages" | tr '\n' ' ')

# Node.js
log "Node.js"
export N_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/n"
export PATH="$N_PREFIX/bin:$PATH"
mkdir -p "$N_PREFIX"/{bin,lib,include,share}
if command -v n >/dev/null; then n lts
else curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/n && chmod +x /tmp/n && /tmp/n lts
fi

# Configure
log "Configure"
command -v docker >/dev/null && {
    sudo systemctl enable --now docker
    groups "$USER" | grep -q docker || sudo usermod -aG docker "$USER"
}
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg" && chmod 700 "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
mkdir -p ~/.local/share/fonts && fc-cache -f
command -v gsettings >/dev/null && {
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
}

# Suckless
log "Suckless"
for t in dwm dmenu dwmblocks; do [ -d "$DOTFILES/$t" ] && sudo make -C "$DOTFILES/$t" clean install; done

# Links
log "Links"
link() { mkdir -p "$(dirname "$2")"; [ -L "$2" ] && rm "$2"; [ -e "$2" ] && mv "$2" "$2.bak"; ln -s "$1" "$2"; }

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

mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES/scripts/.local/bin/"*; do link "$f" "$HOME/.local/bin/$(basename "$f")"; done

mkdir -p "$HOME/.config/systemd/user"
for f in "$DOTFILES/scripts/.config/systemd/user/"*; do link "$f" "$HOME/.config/systemd/user/$(basename "$f")"; done

# Enable wallpaper timer
systemctl --user daemon-reload
systemctl --user enable --now wallpaper.timer 2>/dev/null || true

# Shell
log "Shell"
[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"

log "Done! Reboot to apply."
