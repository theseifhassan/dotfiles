#!/bin/sh
# System setup — installs packages and links dotfiles
set -e
command -v pacman >/dev/null || { echo "Arch Linux required"; exit 1; }

# Pre-flight checks
ping -c 1 archlinux.org >/dev/null 2>&1 || { echo "No network connectivity"; exit 1; }

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
_sudo_pid=$!
trap 'kill $_sudo_pid 2>/dev/null' EXIT

# Auto-snapshot before making changes (btrfs only)
auto_snapshot "pre-install"

# Bootstrap
log "Bootstrap"
command -v paru >/dev/null || {
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
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
    # Hardware
    log "Hardware"
    "$DOTFILES/install/hardware.sh" bluetooth

    # Suckless
    log "Suckless"
    build_suckless
fi

# Links
log "Links"

# Clean up legacy layered config directory
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    install_fonts || true
fi

# Install TPM (shallow clone, background)
TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"
[ ! -d "$TPM_DIR" ] && git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" &
tpm_pid=$!

link_configs

if [ "$DOTFILES_MINIMAL" -eq 0 ]; then
    systemctl --user daemon-reload
fi

# Export XDG vars so installers respect them
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export CLAUDE_CACHE_DIR="$XDG_CACHE_HOME/claude"

# Dev tools via mise
log "Dev tools"
mise install

# OpenCode
log "OpenCode"
command -v opencode >/dev/null || {
    tmpfile=$(mktemp)
    curl -fsSL https://opencode.ai/install -o "$tmpfile"
    chmod +x "$tmpfile"
    bash "$tmpfile"
    rm -f "$tmpfile"
    # Installer hardcodes ~/.opencode/bin — move to ~/.local/bin
    if [ -f "$HOME/.opencode/bin/opencode" ]; then
        mv "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
        rm -rf "$HOME/.opencode"
    fi
}

# Claude Code (installs to ~/.local/bin by default)
log "Claude Code"
command -v claude >/dev/null || {
    tmpfile=$(mktemp)
    curl -fsSL https://claude.ai/install.sh -o "$tmpfile"
    chmod +x "$tmpfile"
    sh "$tmpfile"
    rm -f "$tmpfile"
}

# Shell
log "Shell"
[ "$SHELL" != "$(command -v zsh)" ] && sudo chsh -s "$(command -v zsh)" "$USER"
rm -f "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.bash_logout" "$HOME/.bashrc" "$HOME/.bash_history"

# Clean up non-XDG dotfiles left by installers
# Note: don't remove ~/.claude or ~/.opencode — they may contain binaries
rm -rf "$HOME/.cargo" "$HOME/.claude.json" "$HOME"/.claude.json.backup*

# Wait for background TPM clone
wait "$tpm_pid" 2>/dev/null || true

log "Done! Reboot to apply."
