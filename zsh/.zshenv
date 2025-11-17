# Environment variables - ALWAYS loaded (all shells)

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# XDG-compliant apps
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# X11
export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Session info
export QT_QPA_PLATFORMTHEME="gtk2"
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=dwm
export XDG_CURRENT_DESKTOP=dwm

# PATH (zsh pattern from Arch Wiki)
typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$XDG_DATA_HOME/bob/nvim-bin"
    "$XDG_DATA_HOME/npm/bin"
    "$XDG_DATA_HOME/cargo/bin"
    $path
)
export PATH
