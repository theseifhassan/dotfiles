# fzf configuration and fzf-tab plugin
# Sourced from conf.d after compinit and after `fzf --zsh` in .zshrc.

# --- fzf defaults ---
export FZF_DEFAULT_OPTS="--height=40%"

# --- Completion styling ---
zstyle ':completion:*' menu no                     # Disable default menu (fzf-tab takes over)
zstyle ':completion:*:descriptions' format '[%d]'  # Group headers for fzf-tab

# --- fzf-tab (must be sourced after compinit) ---
source "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
