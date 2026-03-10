HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

autoload -Uz compinit
() {
  local -a _zcompdump=("$XDG_CACHE_HOME/zsh/zcompdump"(N.mh+24))
  if (( ${#_zcompdump} )); then
    compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
  else
    compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"
  fi
}

if (( $+commands[fzf] )) && fzf --zsh &>/dev/null; then
  source <(fzf --zsh)
fi

for conf in "$ZDOTDIR"/conf.d/*.zsh(N); do
  source "$conf"
done
