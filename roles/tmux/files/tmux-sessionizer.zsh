# tmux-sessionizer shell integration
# Adds ~/.local/bin to PATH and binds Ctrl-f to launch the sessionizer.

# Ensure ~/.local/bin is on PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Ctrl-f: open tmux-sessionizer from shell
tmux-sessionizer-widget() {
  tmux-sessionizer
}
zle -N tmux-sessionizer-widget
bindkey '^f' tmux-sessionizer-widget
