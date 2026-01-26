# Define XDG paths before sourcing to avoid circular dependency
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export DOTS_DEFAULT="$XDG_DATA_HOME/dotfiles"

source "$HOME/dotfiles/default/zsh/envs.zsh"
source "$DOTS_DEFAULT/zsh/path.zsh"
export PATH
