# Define XDG paths before sourcing to avoid circular dependency
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Load dotfiles mode (minimal/full)
[ -f "$XDG_STATE_HOME/dotfiles/mode" ] && . "$XDG_STATE_HOME/dotfiles/mode"

# Environment variables
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export CLAUDE_CACHE_DIR="$XDG_CACHE_HOME/claude"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

export EDITOR="nvim"
export VISUAL="nvim"

# Desktop-only env vars
if [ "$DOTFILES_MINIMAL" != "1" ]; then
    export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
    [ -n "$XDG_RUNTIME_DIR" ] && export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
    export BROWSER="google-chrome-stable"
    export QT_QPA_PLATFORMTHEME="gtk2"
    export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"
    export DESKTOP_SESSION="${DESKTOP_SESSION:-dwm}"
    export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-dwm}"
fi

export DOTFILES="$HOME/dotfiles"

# PATH modifications
typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.local/share/mise/shims"
    "$XDG_DATA_HOME/cargo/bin"
    "$XDG_DATA_HOME/go/bin"
    "$XDG_DATA_HOME/npm/bin"
    "$XDG_DATA_HOME/pnpm"
    "$XDG_DATA_HOME/bun/bin"
    $path
)
export PATH
