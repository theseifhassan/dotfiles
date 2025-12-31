export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
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

export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
[ -n "$XDG_RUNTIME_DIR" ] && export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"

export EDITOR="nvim"
export VISUAL="nvim"

export QT_QPA_PLATFORMTHEME="gtk2"
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=dwm
export XDG_CURRENT_DESKTOP=dwm

export DOTFILES="$HOME/dotfiles"
export DOTS_DEFAULT="$XDG_DATA_HOME/dotfiles"
