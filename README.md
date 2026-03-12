# Dotfiles

Ansible-based macOS dotfiles.

## Quick Start

```bash
# Fresh machine
./bootstrap.sh

# Re-run (all roles)
ansible-playbook playbook.yml --ask-vault-pass

# Single role
ansible-playbook playbook.yml -t claude --ask-vault-pass
```

## Roles

| Role | What it does |
|------|-------------|
| ssh | SSH keys + host aliases |
| git | Git config with `includeIf`, GitHub CLI, Graphite CLI |
| zsh | Zsh config under `ZDOTDIR` |
| starship | Minimal prompt |
| mise | Per-project tool/env management |
| ghostty | Terminal emulator |
| tmux | Terminal multiplexer |
| neovim | Neovim |
| claude | Claude Code |
| zed | Zed editor |
| aerospace | Tiling window manager |
| apps | Homebrew casks and CLI tools |
| obs | OBS Studio with DroidCam plugin |
| fonts | Berkeley Mono from private repo |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

## Secrets

Secrets are managed via Ansible Vault (`group_vars/all/vault.yml`). No plaintext secrets on disk.
