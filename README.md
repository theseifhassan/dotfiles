# Dotfiles

Ansible-based macOS dotfiles.

## Quick Start

```bash
# Fresh machine (full setup)
./bootstrap.sh

# Fresh thin client (SSH/git/editor essentials only)
./bootstrap.sh playbook-slim.yml

# Re-run (all roles)
ansible-playbook playbook-default.yml --ask-vault-pass

# Single role
ansible-playbook playbook-default.yml -t claude --ask-vault-pass
```

## Playbooks

| Playbook | Use case |
|----------|----------|
| `playbook-default.yml` | Full workstation setup (all roles) |
| `playbook-slim.yml` | Thin clients that mostly connect to remote servers: `ssh`, `git` (core only, no `gh`/Graphite), `1password`, `slack`, `datagrip`, `figma`, `linear`, `discord`, `claude`, `zed`, `gather`, `obs`, `wispr-flow`, `fonts` (+ `xdg`/`homebrew`, and `zsh` via `claude`) |

## Roles

| Role | What it does |
|------|-------------|
| ssh | SSH keys + host aliases |
| git | Git config with `includeIf`; GitHub CLI + Graphite CLI (skip via `git_install_extras: false`) |
| zsh | Zsh config under `ZDOTDIR` |
| starship | Minimal prompt |
| mise | Per-project tool/env management |
| fzf | Fuzzy finder, fzf-tab completions, history search |
| ghostty | Terminal emulator |
| tmux | Terminal multiplexer + tmux-sessionizer |
| neovim | Neovim (tool only, no config) |
| claude | Claude Code |
| 1password | 1Password + 1Password CLI |
| slack | Slack |
| datagrip | DataGrip |
| figma | Figma |
| linear | Linear |
| discord | Discord |
| zed | Zed editor |
| aerospace | Tiling window manager |
| apps | Homebrew casks and CLI tools |
| gather | Gather Town (from official DMG) |
| wispr-flow | Wispr Flow voice-to-text (from official DMG) |
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

Based on [ThePrimeagen's script](https://github.com/ThePrimeagen/.dotfiles). Searches `~/Desktop` and `~/Documents` for project directories, then creates or switches to a named tmux session rooted at the selected directory.

The script is deployed to `~/.local/bin/tmux-sessionizer` and can also be called directly with a path argument:

```bash
tmux-sessionizer ~/Desktop/my-app
```

## Secrets

Secrets are managed via Ansible Vault (`group_vars/all/vault.yml`). No plaintext secrets on disk.
