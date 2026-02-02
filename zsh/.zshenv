# Define XDG paths before sourcing to avoid circular dependency
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export DOTS_DEFAULT="$XDG_DATA_HOME/dotfiles"

# Load dotfiles mode (minimal/full)
[ -f "$XDG_STATE_HOME/dotfiles/mode" ] && . "$XDG_STATE_HOME/dotfiles/mode"

source "$HOME/dotfiles/default/zsh/envs.zsh"
source "$DOTS_DEFAULT/zsh/path.zsh"
export PATH
