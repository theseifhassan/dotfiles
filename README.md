# Dotfiles

Ansible-based macOS dotfiles.

Two machines, one profile each — both full development environments:

- **Personal** — the Mac mini (`macmini`). Also the Ansible controller: it
  provisions itself over the local connection and pushes to the MacBook over
  Tailscale SSH.
- **Work** — the MacBook (`macbook`). Provisioned by push from the mini; no
  personal credential ever lands on it.

Both machines run the same `site.yml` role list. Profile differences (git
identity, tokens, app picks) live in `group_vars/personal/` and
`group_vars/work/`; the inventory decides which machine is which. Both join
the tailnet with Tailscale SSH enabled, so either can SSH to the other.

## Quick Start

All commands run from the mini (the controller):

```bash
# First-time controller setup (installs toolchain, provisions this machine)
./bootstrap.sh

# Re-run for this machine / the MacBook / both
ansible-playbook site.yml --limit personal --ask-vault-pass
ansible-playbook site.yml --limit work --ask-vault-pass
ansible-playbook site.yml --ask-vault-pass

# Single role
ansible-playbook site.yml -t claude --ask-vault-pass
```

### Provisioning a fresh MacBook

1. Make it reachable over SSH: enable Remote Login (System Settings → General
   → Sharing) on the LAN, or join it to the tailnet with Tailscale SSH.
2. Prepare it from the mini (installs Xcode CLT + Homebrew over SSH):

   ```bash
   ./bootstrap-target.sh macbook
   ```

3. Add the work-profile vault keys if not present (see Secrets below), then:

   ```bash
   ansible-playbook site.yml --limit work --ask-vault-pass
   ```

The roles that touch system settings need sudo; `ansible_become_password` is
wired per profile from the vault, so `--ask-vault-pass` alone is enough (no
separate `--ask-become-pass`).

## Roles

| Role | What it does |
|------|-------------|
| ssh | Profile SSH key + machine key from the vault; SSH config |
| git | Git config with the machine's single profile identity; GitHub CLI + Graphite CLI |
| zsh | Zsh config under `ZDOTDIR` (vi mode + native prompt) |
| mise | Per-project tool/env management; renders profile secrets |
| fzf | Fuzzy finder, fzf-tab completions, history search |
| ghostty | Terminal emulator |
| tmux | Terminal multiplexer + tmux-sessionizer |
| neovim | Neovim 0.12 + owned config (vim.pack, native LSP, native completion); installs language servers via brew + mise npm backend (no Mason) |
| claude | Claude Code (the machine's profile account) |
| zed | Zed editor |
| apps | Per-app installs — GUI casks (Chrome, Notion, Slack, Figma, Linear, Discord, DataGrip, 1Password), official-DMG apps (Gather, Wispr Flow, Raycast Beta, Alcove; shared install routine), and dev CLIs (Lazygit, ripgrep, gcloud, gws); each task tagged, so `-t slack` targets one and `-t apps` runs all. Slack + Gather work-only, Discord personal-only |
| obs | OBS Studio with DroidCam plugin (personal only) |
| fonts | Berkeley Mono from a private personal repo — cloned on the controller, pushed to targets |
| tailscale | Headless `tailscaled` system daemon; joins the tailnet with Tailscale SSH on every machine |
| colima | Docker runtime via Colima |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

App split: shared on both — Chrome, Notion, Figma, Linear, DataGrip, Raycast
Beta, Wispr Flow, Alcove, 1Password, Zed. Work-only — Slack, Gather.
Personal-only — Discord, OBS.

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

## mise env

[mise](https://mise.jdx.dev) is the single global owner of env vars, secrets,
and tool versions. The global config (`~/.config/mise/config.toml`, rendered
per profile by the `mise` role, mode 0600) carries everything in one place:
`[env]` (EDITOR/VISUAL, `CLAUDE_CONFIG_DIR`, `FZF_DEFAULT_OPTS`,
`SAW_WORKTREE_ROOT`, and the profile secrets like `GH_TOKEN` inline from the
vault) and `[tools]` (node, pnpm, bun). Rotating a secret means editing the
vault and re-running the playbook.

The only env vars set outside mise are the bootstrap ones mise itself depends
on: the XDG paths and `ZDOTDIR`, exported from `~/.zshenv` before mise
activates. Everything else — including new API keys — goes in the mise
config, never in zsh files.

General CLIs (`gh`, `gt`, `lazygit`) are installed globally via Homebrew (the
`git` and `apps` roles), so they're deliberately not managed by mise.

## Secrets

Secrets are encrypted in the repo via Ansible Vault (`group_vars/all/vault.yml`)
and rendered at playbook time into the machine's mise config
(`~/.config/mise/config.toml`, mode 0600). Nothing plaintext is ever
committed. The vault holds both profiles' secrets; each machine only ever
receives its own profile's.

Keys the vault must hold (add with `ansible-vault edit group_vars/all/vault.yml`):

| Key | Used by |
|-----|---------|
| `vault_sudo_password` | personal become password (mini) |
| `vault_sudo_password_work` | work become password (MacBook) |
| `vault_gh_token_personal` / `vault_gh_token_work` | mise config `[env]` per profile |
| `vault_graphite_tokens.personal` / `.work` | Graphite user config per profile |
| `vault_ssh_keys.personal` / `.work` | the profile SSH keypair per machine |
| `vault_machine_ssh_keys.<hostname>` | per-machine SSH keypair (`macmini`, `macbook`) |
| `vault_tailscale_authkey` | optional non-interactive `tailscale up` |
