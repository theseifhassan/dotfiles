# Interactive shell config only

bindkey -v
bindkey -s "^f" "sessionizer.sh\n"

source <(fzf --zsh)

# Enable prompt substitution
setopt PROMPT_SUBST

# Git branch function
git_branch() {
    local branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    if [ -n "$branch" ]; then
        echo " [${branch}]"
    fi
}

# Prompt
export PS1='%n@%m %1~$(git_branch) $ '

# pnpm (XDG-compliant)
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun (XDG-compliant)
export BUN_INSTALL="${XDG_DATA_HOME:-$HOME/.local/share}/bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# tj/n (Node Manager)
export N_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/n"
export PATH="$N_PREFIX/bin:$PATH"
