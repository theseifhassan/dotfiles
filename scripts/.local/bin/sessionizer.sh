#!/bin/sh
set -e
# Tmux sessionizer - quick project switcher with dev layout
# Usage: sessionizer.sh [directory]
#
# Layout (new sessions only):
#   Window 1 "edit"  — nvim (left 60%) | shell (right 40%)
#   Window 2 "shell" — empty shell for server / one-off commands
#   Window 3 "git"   — lazygit

command -v fzf >/dev/null || { echo "fzf required"; exit 1; }
command -v tmux >/dev/null || { echo "tmux required"; exit 1; }

SEARCH_DIRS="${SESSIONIZER_DIRS:-$HOME/Projects $HOME/dotfiles $HOME}"

if [ -n "$1" ]; then
    selected="$1"
else
    # Word splitting is intentional here for multiple directories
    # shellcheck disable=SC2086
    selected=$(find $SEARCH_DIRS -mindepth 1 -maxdepth 1 -type d 2>/dev/null | fzf) || exit 0
fi

[ -z "$selected" ] && exit 0

name=$(basename "$selected" | tr . _)

if ! tmux has-session -t="$name" 2>/dev/null; then
    # Window 1: editor + agent
    tmux new-session -ds "$name" -c "$selected" -n "edit"
    tmux send-keys -t "$name:edit" "nvim" Enter
    tmux split-window -t "$name:edit" -h -l 30% -c "$selected"

    # Window 2: shell
    tmux new-window -t "$name" -n "shell" -c "$selected"

    # Window 3: lazygit
    tmux new-window -t "$name" -n "git" -c "$selected"
    tmux send-keys -t "$name:git" "lazygit" Enter

    # Focus on editor window, left pane
    tmux select-window -t "$name:edit"
    tmux select-pane -t "$name:edit.1"
fi

if [ -z "$TMUX" ]; then
    tmux attach -t "$name"
else
    tmux switch-client -t "$name"
fi
