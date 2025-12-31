#!/bin/sh
# Tmux sessionizer - quick project switcher
# Usage: sessionizer.sh [directory]

SEARCH_DIRS="${SESSIONIZER_DIRS:-$HOME/Projects $HOME/dotfiles $HOME}"

if [ -n "$1" ]; then
    selected="$1"
else
    selected=$(find $SEARCH_DIRS -mindepth 1 -maxdepth 1 -type d 2>/dev/null | fzf)
fi

[ -z "$selected" ] && exit 0

name=$(basename "$selected" | tr . _)

if [ -z "$TMUX" ]; then
    tmux new-session -As "$name" -c "$selected"
else
    if ! tmux has-session -t="$name" 2>/dev/null; then
        tmux new-session -ds "$name" -c "$selected"
    fi
    tmux switch-client -t "$name"
fi
