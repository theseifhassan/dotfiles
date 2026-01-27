command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)" 2>/dev/null
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

bindkey -s "^f" "sessionizer.sh\n"
