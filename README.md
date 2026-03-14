# Dotfiles

Ansible-based macOS dotfiles.

## Quick Start

```bash
# Fresh machine
./bootstrap.sh

# Re-run (all roles)
ansible-playbook playbook.yml --ask-vault-pass

# Single role
ansible-playbook playbook.yml -t opencode --ask-vault-pass
```

## Roles

| Role | What it does |
|------|-------------|
| ssh | SSH keys + host aliases |
| git | Git config with `includeIf`, GitHub CLI, Graphite CLI |
| zsh | Zsh config under `ZDOTDIR` |
| starship | Minimal prompt |
| mise | Per-project tool/env management |
| fzf | Fuzzy finder, fzf-tab completions, history search |
| ghostty | Terminal emulator |
| tmux | Terminal multiplexer + tmux-sessionizer |
| neovim | Neovim |
| claude | Claude Code |
| opencode | OpenCode |
| zed | Zed editor |
| aerospace | Tiling window manager |
| apps | Homebrew casks and CLI tools |
| obs | OBS Studio with DroidCam plugin |
| fonts | Berkeley Mono from private repo |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

## Shell Keybindings

| Keybinding | Context | Action |
|------------|---------|--------|
| `Ctrl-r` | Shell | fzf-powered reverse history search |
| `**<TAB>` | Shell | fzf file/path completion trigger |
| `<TAB>` | Shell | fzf-tab fuzzy completion (replaces default menu) |
| `Ctrl-f` | Shell | Launch tmux-sessionizer |
| `<prefix> f` | tmux | Launch tmux-sessionizer |

## tmux-sessionizer

Based on [ThePrimeagen's script](https://github.com/ThePrimeagen/.dotfiles). Searches `~/Projects` and `~/Documents` for project directories, then creates or switches to a named tmux session rooted at the selected directory.

The script is deployed to `~/.local/bin/tmux-sessionizer` and can also be called directly with a path argument:

```bash
tmux-sessionizer ~/Projects/my-app
```

## Secrets

Secrets are managed via Ansible Vault (`group_vars/all/vault.yml`). No plaintext secrets on disk.
