# Interactive shell config

# Options
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

# Aliases
alias v='nvim'
alias vim='nvim'

# Shell integrations - cached, regenerate on version change
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_cache_dir"

_cached_init() {
    local cmd="$1" cache="$_cache_dir/${1}-init.zsh" ver_file="$cache.ver"
    command -v "$cmd" >/dev/null 2>&1 || return 1

    local ver=$("$cmd" --version 2>/dev/null | head -1)
    if [[ -r "$cache" && -r "$ver_file" && "$(cat "$ver_file")" == "$ver" ]]; then
        source "$cache"
    else
        case "$cmd" in
            mise)     mise activate zsh > "$cache" ;;
            starship) starship init zsh > "$cache" ;;
            fzf)      fzf --zsh > "$cache" 2>/dev/null ;;
            zoxide)   zoxide init zsh > "$cache" ;;
        esac
        echo "$ver" > "$ver_file"
        source "$cache"
    fi
}

_cached_init mise
_cached_init starship
_cached_init fzf
_cached_init zoxide

unfunction _cached_init
unset _cache_dir

bindkey -s "^f" "sessionizer.sh\n"

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# opencode
export PATH=/home/seifhassan/.opencode/bin:$PATH
