HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Cursor shape: block in normal mode, beam in insert mode
function zle-keymap-select zle-line-init {
  case $KEYMAP in
    vicmd)      printf '\e[2 q' ;;  # block
    main|viins) printf '\e[6 q' ;;  # beam
  esac
}
zle -N zle-keymap-select
zle -N zle-line-init

# Prompt (native zsh): user@host:path [branch] $   ($ turns to !$ on error)
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' [%b]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a]'
precmd() { vcs_info }
PROMPT='%n@%m:%~${vcs_info_msg_0_} %(?.$.!$) '

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
