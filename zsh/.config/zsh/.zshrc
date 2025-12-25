# Interactive shell config only

# Vi mode
bindkey -v

# fzf
source <(fzf --zsh)

eval "$(starship init zsh)"
#
# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
