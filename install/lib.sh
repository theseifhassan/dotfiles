#!/bin/sh
# Shared functions for dotfiles scripts

# Load persisted mode if not already set
if [ -z "$DOTFILES_MINIMAL" ]; then
    _mode_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/mode"
    if [ -f "$_mode_file" ]; then
        # shellcheck disable=SC1090
        . "$_mode_file"
    fi
fi
DOTFILES_MINIMAL="${DOTFILES_MINIMAL:-0}"

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

# Log with prefix (also persists to log file)
_log_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/install.log"
mkdir -p "$(dirname "$_log_file")"
log() {
    echo ">>> $1" | tee -a "$_log_file"
}

# Get packages from a list file (skip comments and blanks)
pkg_list() {
    grep -vE "^\s*#|^\s*$" "$1"
}

# Expected systemd services based on mode
expected_services() {
    echo "docker tailscaled sshd"
    [ "$DOTFILES_MINIMAL" -eq 0 ] && echo "bluetooth"
}

# Take a btrfs auto-snapshot if on btrfs
auto_snapshot() {
    if findmnt -n -o FSTYPE / | grep -q btrfs; then
        sudo mkdir -p /.snapshots
        sudo btrfs subvolume snapshot -r / "/.snapshots/$(date +%Y-%m-%d_%H%M%S)__${1:-auto}" >/dev/null
        log "Auto-snapshot taken"
    fi
}

# Symlink definitions — single source of truth
# Each function takes a callback and calls it with (source, target) pairs

_base_links() {
    "$1" "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
    "$1" "$DOTFILES/zsh/.config/zsh" "$HOME/.config/zsh"
    "$1" "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"
    "$1" "$DOTFILES/tmux/.config/tmux" "$HOME/.config/tmux"
    "$1" "$DOTFILES/git/.config/git" "$HOME/.config/git"
    "$1" "$DOTFILES/ripgrep/.config/ripgrep" "$HOME/.config/ripgrep"
    "$1" "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"
    "$1" "$DOTFILES/opencode/.config/opencode" "$HOME/.config/opencode"
    "$1" "$DOTFILES/npm/.config/npm" "$HOME/.config/npm"
    "$1" "$DOTFILES/mise/.config/mise" "$HOME/.config/mise"
    "$1" "$DOTFILES/ssh/.ssh/config" "$HOME/.ssh/config"
    "$1" "$DOTFILES/1password/.config/1Password/ssh/agent.toml" "$HOME/.config/1Password/ssh/agent.toml"
    for f in "$DOTFILES/scripts/.local/bin/"*; do "$1" "$f" "$HOME/.local/bin/$(basename "$f")"; done
}

_desktop_links() {
    "$1" "$DOTFILES/x11/.config/x11" "$HOME/.config/x11"
    "$1" "$DOTFILES/ghostty/.config/ghostty" "$HOME/.config/ghostty"
    "$1" "$DOTFILES/picom/.config/picom" "$HOME/.config/picom"
    "$1" "$DOTFILES/dunst/.config/dunst" "$HOME/.config/dunst"
    "$1" "$DOTFILES/fontconfig/.config/fontconfig" "$HOME/.config/fontconfig"
    "$1" "$DOTFILES/chrome/.config/chrome-flags.conf" "$HOME/.config/chrome-flags.conf"
    if [ -d "$DOTFILES/wallpapers" ] && find "$DOTFILES/wallpapers" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | grep -q .; then
        mkdir -p "$HOME/Pictures"
        "$1" "$DOTFILES/wallpapers" "$HOME/Pictures/Wallpapers"
    fi
    mkdir -p "$HOME/.config/systemd/user"
    for f in "$DOTFILES/scripts/.config/systemd/user/"*; do "$1" "$f" "$HOME/.config/systemd/user/$(basename "$f")"; done
}

for_each_link() {
    _base_links "$1"
    [ "$DOTFILES_MINIMAL" -eq 0 ] && _desktop_links "$1"
}

link_configs() {
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    mkdir -p "$HOME/.local/bin"
    for_each_link link
    chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
}

# Build suckless tools (dwm, dmenu, dwmblocks)
# Usage: build_suckless [target]  (default: all)
build_suckless() {
    _target="${1:-all}"
    if [ "$_target" = "all" ]; then
        pids=""
        for d in dwm dmenu dwmblocks; do
            [ -d "$DOTFILES/$d" ] && {
                sudo make -C "$DOTFILES/$d" clean install &
                pids="$pids $!"
            }
        done
        failed=""
        for pid in $pids; do wait "$pid" || failed="$failed $pid"; done
        [ -n "$failed" ] && { echo "ERROR: suckless build failed"; exit 1; }
    else
        [ ! -d "$DOTFILES/$_target" ] && { echo "Unknown target: $_target (available: dwm dmenu dwmblocks)"; exit 1; }
        sudo make -C "$DOTFILES/$_target" clean install
    fi
}

# Reload running suckless tools after a rebuild
reload_suckless() {
    pgrep -x dwm >/dev/null && pkill -HUP dwm
    pgrep -x dwmblocks >/dev/null && { killall dwmblocks; dwmblocks & }
}

# Install fonts from $DOTFILES/fonts if present
# Returns 1 if no fonts found
install_fonts() {
    if [ -d "$DOTFILES/fonts" ] && find "$DOTFILES/fonts" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | grep -q .; then
        log "Installing fonts..."
        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
        find "$DOTFILES/fonts" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/" \;
        fc-cache -f
        return 0
    fi
    return 1
}
