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
| zsh | Zsh config under `ZDOTDIR` (vi mode + native prompt) |
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
| apps | Homebrew casks and CLI tools (Google Chrome, Lazygit) |
| gather | Gather Town (from official DMG) |
| wispr-flow | Wispr Flow voice-to-text (from official DMG) |
| raycast | Raycast Beta (from official DMG) |
| obs | OBS Studio with DroidCam plugin |
| fonts | Berkeley Mono from private repo |
| tailscale | Headless `tailscaled` system daemon (joins the tailnet) |
| server | Sleep prevention for an always-on host (server playbook only) |
| colima | Headless Docker runtime via Colima (server playbook only) |
| onepassword | Headless `op` via 1Password service-account token (server playbook only) |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

## Playbooks

Pick the playbook that matches the machine (pass it to `bootstrap.sh`, or run
`ansible-playbook <file> --ask-vault-pass` directly):

| Playbook | For | What it provisions |
|----------|-----|--------------------|
| `playbook-default.yml` | Primary dev Mac (default) | Full toolchain + apps, plus `tailscale` to join the tailnet |
| `playbook-slim.yml` | Thin clients (e.g. MacBook) | Essentials only — core git (no gh/Graphite), key apps, and `tailscale` |
| `playbook-server.yml` | Always-on dev server (Mac mini) | Everything in default **plus** server roles: Tailscale SSH, sleep prevention, Colima, headless `op` |

```bash
./bootstrap.sh                       # playbook-default.yml
./bootstrap.sh playbook-slim.yml     # thin client
./bootstrap.sh playbook-server.yml   # dev server
```

The server playbook's roles touch system settings and need sudo;
`ansible_become_password` is wired from the vault, so `--ask-vault-pass` alone
is enough (no separate `--ask-become-pass`).

See [docs/dev-server-migration.md](docs/dev-server-migration.md) for the full
Mac-mini-as-dev-server runbook.

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

## mise presets

Project toolchains are managed with [mise](https://mise.jdx.dev). To avoid
copying near-identical config into every repo, a project's `mise.toml` is
scaffolded from a **preset** (the toolchain) plus a **profile** (work/personal
env vars):

```bash
mise run init node          # node toolchain; profile auto-detected from git remote
mise run init node work     # force the work profile
mise run init node personal # force the personal profile
```

The profile is auto-detected from the repo's git remote (work if it matches the
`work.github.com` host, else personal), mirroring the `git` role. Scaffold
before adding a remote and it defaults to personal — pass `work` to override.

Presets live under `~/.config/mise/presets/`:

- `node.toml` etc. — the toolchain (`node`, `pnpm`, common tasks), identical
  across profiles.
- `_env-work.toml` / `_env-personal.toml` — the profile-varying env vars
  (`GH_TOKEN`, `GREPTILE_API_KEY`, `GRAPHITE_PROFILE`), with secrets pulled from
  1Password via `op` at runtime. This mirrors the `git` role's work/personal
  split (work = `~/Desktop/sky*`, personal by default).

General CLIs (`gh`, `gt`, `lazygit`) are installed globally via Homebrew (the
`git` and `apps` roles), so they're deliberately not managed by mise.

## Secrets

Secrets are managed via Ansible Vault (`group_vars/all/vault.yml`). No plaintext secrets on disk.
