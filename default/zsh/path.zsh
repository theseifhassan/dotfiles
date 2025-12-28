typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$XDG_DATA_HOME/cargo/bin"
    "$XDG_DATA_HOME/go/bin"
    "$XDG_DATA_HOME/npm/bin"
    "$XDG_DATA_HOME/bob/nvim-bin"
    "$XDG_DATA_HOME/n/bin"
    "$XDG_DATA_HOME/pnpm"
    "$XDG_DATA_HOME/bun/bin"
    $path
)
export PATH
