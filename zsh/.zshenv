# ~/.zshenv - Environment variables (ALWAYS loaded)

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# XDG-compliant apps
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
export N_PREFIX="$XDG_DATA_HOME/n"

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"

# bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Homebrew (must be before PATH setup)
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$XDG_DATA_HOME/npm/bin"
    "$XDG_DATA_HOME/cargo/bin"
    "$GOPATH/bin"
    "$N_PREFIX/bin"
    "$PNPM_HOME"
    "$BUN_INSTALL/bin"
    "$HOME/.opencode/bin"
    $path
)
export PATH

# bun completions
[ -s "/Users/seifhassan/.bun/_bun" ] && source "/Users/seifhassan/.bun/_bun"
