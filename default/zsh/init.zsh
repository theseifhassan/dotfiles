command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)" 2>/dev/null

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

bindkey -s "^f" "sessionizer.sh\n"
