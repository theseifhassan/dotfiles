# Dotfiles

Ansible-based macOS dotfiles.

Two machine profiles:

- **Dev server** (`playbook-server.yml`) — the always-on Mac mini, the primary
  workstation. Full developer toolchain + GUI apps + server infrastructure.
- **Thin client** (`playbook-thin.yml`) — a MacBook that connects to the dev
  server over Tailscale SSH. GUI apps and Claude Code only, no dev toolchain.

## Quick Start

```bash
# Dev server (default)
./bootstrap.sh

# Thin client
./bootstrap.sh playbook-thin.yml

# Re-run (all roles)
ansible-playbook playbook-server.yml --ask-vault-pass

# Single role
ansible-playbook playbook-server.yml -t claude --ask-vault-pass
```

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
| 1password | 1Password app + `op` CLI; on the server (`op_headless: true`) also deploys a service-account token for headless `op read` (tag `op`) |
| zed | Zed editor |
| casks | Trivial single-cask GUI apps (Chrome, Notion, Slack, Figma, Linear, Discord, DataGrip); each task is tagged, so `-t slack` targets one and `-t casks` runs all |
| apps | Loose developer CLIs with no role of their own (Lazygit, ripgrep) — server only |
| dmg | GUI apps installed from official DMGs (Gather Town, Wispr Flow, Raycast Beta); shared install logic, each tagged — `-t raycast` targets one, `-t dmg` runs all |
| obs | OBS Studio with DroidCam plugin |
| fonts | Berkeley Mono from private repo |
| tailscale | Headless `tailscaled` system daemon (joins the tailnet) |
| server | Sleep prevention for an always-on host (server playbook only) |
| colima | Headless Docker runtime via Colima (server playbook only) |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

## Playbooks

Pick the playbook that matches the machine (pass it to `bootstrap.sh`, or run
`ansible-playbook <file> --ask-vault-pass` directly):

| Playbook | For | What it provisions |
|----------|-----|--------------------|
| `playbook-server.yml` | Always-on dev server (Mac mini), the primary workstation | Full developer toolchain (Claude Code, Ghostty, Lazygit, mise, Neovim, gh, Graphite, 1Password CLI, fzf, ripgrep, tmux, Colima) + GUI apps, **plus** server roles: Tailscale SSH, sleep prevention, Colima, headless `op` |
| `playbook-thin.yml` | Thin clients (e.g. MacBook) | GUI apps + Claude Code only — no dev toolchain. Keeps `ssh`, core `git` (no gh/Graphite), and `tailscale` to reach the server |

GUI apps on both profiles: Google Chrome, Raycast Beta, Slack, Gather, Figma,
Linear, Notion, 1Password, Wispr Flow, Zed, DataGrip, Discord, OBS.

```bash
./bootstrap.sh                       # playbook-server.yml (default)
./bootstrap.sh playbook-thin.yml     # thin client
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
