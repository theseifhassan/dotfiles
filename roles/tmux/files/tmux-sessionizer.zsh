# tmux-sessionizer shell integration
# Adds ~/.local/bin to PATH and binds Ctrl-f to launch the sessionizer.

# Ensure ~/.local/bin is on PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Ctrl-f: open tmux-sessionizer from shell.
# Run it via accept-line rather than invoking it inside the widget: zle owns
# the terminal while a widget runs, so tmux attach/new-session would fail
# with "open terminal failed: not a terminal".
tmux-sessionizer-widget() {
  BUFFER="tmux-sessionizer"
  zle accept-line
}
zle -N tmux-sessionizer-widget
bindkey '^f' tmux-sessionizer-widget
