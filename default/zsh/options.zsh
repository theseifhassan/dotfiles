# Zsh shell options
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# compinit with 24-hour cache
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${_zcompdump%/*}"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi
unset _zcompdump

bindkey -v
export KEYTIMEOUT=1
