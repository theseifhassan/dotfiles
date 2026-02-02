#!/bin/sh
# System setup — installs packages and links dotfiles
set -e
command -v pacman >/dev/null || { echo "Arch Linux required"; exit 1; }

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export DOTFILES

# Parse --minimal flag
DOTFILES_MINIMAL=0
for arg in "$@"; do
    case "$arg" in
        --minimal) DOTFILES_MINIMAL=1 ;;
    esac
done
export DOTFILES_MINIMAL

# Persist mode for future dot commands
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
mkdir -p "$STATE_DIR"
echo "DOTFILES_MINIMAL=$DOTFILES_MINIMAL" > "$STATE_DIR/mode"

# shellcheck source=lib.sh
. "$DOTFILES/install/lib.sh"

# Cache sudo credentials upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Auto-snapshot before making changes (btrfs only)
auto_snapshot "pre-install"

# Bootstrap
log "Bootstrap"
command -v paru >/dev/null || {
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    rm -rf /tmp/paru
}

# Enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf 2>/dev/null || true

# Configure makepkg for parallel builds
MAKEPKG_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/pacman/makepkg.conf"
mkdir -p "$(dirname "$MAKEPKG_CONF")"
[ ! -f "$MAKEPKG_CONF" ] && cat > "$MAKEPKG_CONF" << 'EOF'
MAKEFLAGS="-j$(nproc)"
BUILDDIR=/tmp/makepkg
EOF

# Packages
log "Packages"
sudo pacman -Syu --noconfirm
# shellcheck disable=SC2046
paru -S --needed --noconfirm $(grep -vE "^\s*#|^\s*$" "$DOTFILES/install/packages" | tr '\n' ' ')
if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    # shellcheck disable=SC2046
    paru -S --needed --noconfirm $(grep -vE "^\s*#|^\s*$" "$DOTFILES/install/packages.desktop" | tr '\n' ' ')
fi

# Configure
log "Configure"
# Services in parallel
_svc_pids=""
{
    command -v docker >/dev/null && {
        sudo systemctl enable --now docker
        groups "$USER" | grep -q docker || sudo usermod -aG docker "$USER"
    } || true
} & _svc_pids="$_svc_pids $!"
{
    command -v tailscale >/dev/null && sudo systemctl enable --now tailscaled || true
} & _svc_pids="$_svc_pids $!"
{
    command -v powerprofilesctl >/dev/null && {
        sudo systemctl enable --now power-profiles-daemon
        # Default to performance on desktops (no battery)
        [ ! -d /sys/class/power_supply/BAT0 ] && powerprofilesctl set performance || true
    } || true
} & _svc_pids="$_svc_pids $!"
if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    {
        command -v autorandr >/dev/null && sudo systemctl enable autorandr.service 2>/dev/null || true
    } & _svc_pids="$_svc_pids $!"
fi
# shellcheck disable=SC2086
wait $_svc_pids 2>/dev/null || true

# Non-parallel fast operations
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg" && chmod 700 "${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    mkdir -p ~/.local/share/fonts
    command -v gsettings >/dev/null && {
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    }

    # User directories
    log "User directories"
    xdg-user-dirs-update
fi
mkdir -p "$HOME/Projects"

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    # Touchpad
    log "Touchpad"
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo cp "$DOTFILES/x11/30-touchpad.conf" /etc/X11/xorg.conf.d/

    # Hardware
    log "Hardware"
    # Disable NVIDIA GPU by default for maximum battery life
    if lspci | grep -qi nvidia && command -v envycontrol >/dev/null; then
        log "Disabling NVIDIA GPU (use 'dot hardware nvidia' to enable)"
        sudo envycontrol -s integrated --no-confirm || true
    fi
    "$DOTFILES/install/hardware.sh" bluetooth

    # Suckless - compile in parallel
    log "Suckless"
    pids=""
    for t in dwm dmenu dwmblocks; do
        [ -d "$DOTFILES/$t" ] && {
            sudo make -C "$DOTFILES/$t" clean install &
            pids="$pids $!"
        }
    done
    for pid in $pids; do wait "$pid" || true; done
fi

# Links
log "Links"

# Copy defaults to XDG_DATA_HOME
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
cp -r "$DOTFILES/default" "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    # Install fonts if present
    if [ -d "$DOTFILES/fonts" ] && find "$DOTFILES/fonts" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | grep -q .; then
        log "Installing fonts..."
        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
        cp -r "$DOTFILES/fonts/"* "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/" 2>/dev/null || true
        fc-cache -f
    fi
fi

# Install TPM (shallow clone, background)
TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"
[ ! -d "$TPM_DIR" ] && git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" &
tpm_pid=$!

link_configs

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    # Enable wallpaper timer
    systemctl --user daemon-reload
    systemctl --user enable --now wallpaper.timer 2>/dev/null || true
fi

# OpenCode
log "OpenCode"
command -v opencode >/dev/null || curl -fsSL https://opencode.ai/install | bash

# Claude Code
log "Claude Code"
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | sh

# Shell
log "Shell"
[ "$SHELL" != "$(command -v zsh)" ] && sudo chsh -s "$(command -v zsh)" "$USER"
rm -f "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.bash_logout" "$HOME/.bashrc" "$HOME/.bash_history"

# Wait for background TPM clone
wait "$tpm_pid" 2>/dev/null || true

log "Done! Reboot to apply."
