# Cache shell integrations - regenerate on version change
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
