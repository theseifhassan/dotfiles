# Modular Dotfiles System - Design Document

**Version:** 0.1.0-draft
**Date:** 2026-03-07
**Based on:** [Requirements v0.2.0](./requirements.md)

---

## 1. Repository Structure

```
dotfiles/
├── bootstrap.sh                  # Single entry point for fresh machines
├── Makefile                      # Convenience targets (bootstrap, apply, lint, etc.)
├── ansible.cfg                   # Ansible configuration
├── playbook.yml                  # Top-level playbook that composes all roles
├── group_vars/
│   └── all.yml                   # Shared variables (identities, paths, repo URLs)
├── docs/
│   ├── requirements.md
│   └── design.md
└── roles/
    ├── xdg/                      # XDG directory scaffolding
    ├── homebrew/                  # Ensure Homebrew is present and healthy
    ├── onepassword/               # 1Password app + CLI
    ├── ssh/                       # SSH keys + config (identity-aware)
    ├── git/                       # Git config + identity switching
    ├── zsh/                       # Shell config (ZDOTDIR under XDG)
    ├── starship/                  # Starship prompt
    ├── mise/                      # mise installation + global config
    ├── ghostty/                   # Ghostty terminal
    ├── tmux/                      # Tmux multiplexer
    ├── neovim/                    # Neovim editor
    ├── claude-code/               # Claude Code + MCP server config
    ├── zed/                       # Zed editor
    ├── aerospace/                 # Aerospace WM
    ├── raycast/                   # Raycast launcher
    ├── gh/                        # GitHub CLI
    ├── graphite/                  # Graphite CLI + identity profiles
    ├── fonts/                     # Berkeley Mono (private repo)
    └── apps/                      # Remaining GUI apps (Chrome, Figma, etc.)
```

---

## 2. Role Anatomy

Every role follows the standard Ansible role layout. Only the directories that are needed are created — no empty scaffolding.

```
roles/<name>/
├── tasks/
│   └── main.yml          # Task entry point
├── templates/             # Jinja2 templates for config files (if needed)
├── files/                 # Static config files to copy verbatim (if needed)
├── defaults/
│   └── main.yml           # Default variables for the role (if needed)
└── vars/
    └── main.yml           # Internal variables (if needed)
```

### Design rules for roles

| Rule | Rationale |
|---|---|
| A role MUST NOT use `meta/main.yml` dependencies | Keeps roles decoupled. The playbook controls ordering. |
| A role MUST install its own Homebrew packages | Self-contained brick. |
| A role MUST be taggable and individually runnable | `ansible-playbook playbook.yml -t <role>` |
| A role MUST be idempotent | Every task uses a module that checks state before acting, or uses `creates`/`when` guards. |
| A role that needs secrets MUST use the `op` CLI or the `onepassword` lookup | No plaintext secrets in the repo. |

---

## 3. Bootstrap Sequence

`bootstrap.sh` is the single command that takes a bare macOS install to a fully configured system.

```
┌─────────────────────────────────────────────────────┐
│                   bootstrap.sh                      │
├─────────────────────────────────────────────────────┤
│ 1. Install Xcode Command Line Tools (if missing)    │
│ 2. Install Homebrew (if missing)                    │
│ 3. brew install ansible 1password-cli               │
│ 4. Prompt: "Sign in to 1Password CLI" (op signin)  │
│ 5. ansible-playbook playbook.yml                    │
└─────────────────────────────────────────────────────┘
```

**Key constraint:** Steps 1–4 are the only things the bootstrap script does directly. Everything else is an Ansible role. This keeps the bootstrap script minimal and pushes all complexity into idempotent roles.

**Re-running:** On an already-configured machine, `make apply` (which calls `ansible-playbook playbook.yml`) is the only command needed. The bootstrap script is idempotent and safe to re-run.

---

## 4. Playbook Ordering

The top-level `playbook.yml` sequences roles. While roles have no declared dependencies, the playbook enforces a logical ordering so prerequisites are satisfied:

```yaml
# playbook.yml
- hosts: localhost
  connection: local
  roles:
    # --- Foundation ---
    - role: xdg            # Create XDG directory structure first
    - role: homebrew        # Ensure Homebrew is healthy
    - role: onepassword     # 1Password app + CLI

    # --- Identity & Credentials ---
    - role: ssh             # SSH keys from 1Password
    - role: git             # Git config + identity switching
    - role: gh              # GitHub CLI
    - role: graphite        # Graphite CLI + profiles from 1Password

    # --- Shell ---
    - role: zsh             # Shell config
    - role: starship        # Prompt
    - role: mise            # Project-scoped tool management

    # --- Editors & Terminal ---
    - role: ghostty
    - role: tmux
    - role: neovim
    - role: claude-code     # Claude Code + MCP servers
    - role: zed

    # --- Desktop ---
    - role: aerospace
    - role: raycast
    - role: apps            # Chrome, Figma, Linear, Slack, Gather

    # --- Fonts (requires SSH for private repo) ---
    - role: fonts
```

**Why this order matters:**
- `xdg` first → all roles can rely on XDG directories existing.
- `onepassword` before `ssh` → SSH key retrieval needs `op`.
- `ssh` before `fonts` → cloning the private font repo needs SSH keys.
- `ssh` before `git` → Git signing may reference SSH keys.

---

## 5. XDG Compliance Strategy

### 5.1 The `xdg` role

This role creates the base directory tree and exports env vars. It writes a file that the `zsh` role sources early in shell init.

```
~/.config/           # XDG_CONFIG_HOME
~/.local/share/      # XDG_DATA_HOME
~/.local/state/      # XDG_STATE_HOME
~/.cache/            # XDG_CACHE_HOME
```

Exported in `$XDG_CONFIG_HOME/zsh/.zshenv` (sourced via `~/.zshenv` → `ZDOTDIR` redirect):

```sh
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
```

### 5.2 Per-tool XDG mapping

| Tool | Native XDG? | Strategy |
|---|---|---|
| Zsh | No | Set `ZDOTDIR=$XDG_CONFIG_HOME/zsh` in `~/.zshenv` (the one unavoidable dotfile) |
| Git | Yes | `$XDG_CONFIG_HOME/git/config` (native) |
| SSH | No | `~/.ssh/` is hardcoded by OpenSSH. Keep as-is — this is an accepted exception. |
| Starship | Yes | `$XDG_CONFIG_HOME/starship.toml` via `STARSHIP_CONFIG` env var |
| Ghostty | Yes | `$XDG_CONFIG_HOME/ghostty/config` (native) |
| Tmux | Partial | `$XDG_CONFIG_HOME/tmux/tmux.conf` (native since tmux 3.1) |
| Neovim | Yes | `$XDG_CONFIG_HOME/nvim/` (native) |
| mise | Yes | `$XDG_CONFIG_HOME/mise/` (native) |
| Aerospace | Yes | `$XDG_CONFIG_HOME/aerospace/` (native) |
| Graphite | Yes | `$XDG_CONFIG_HOME/graphite/` (native) |
| Claude Code | Partial | `$XDG_CONFIG_HOME/claude/` — verify at implementation time |
| gh CLI | Yes | `$XDG_CONFIG_HOME/gh/` via `GH_CONFIG_DIR` env var |

**Accepted home-directory exceptions:**
- `~/.zshenv` — single-line `ZDOTDIR` redirect (unavoidable — Zsh loads this before anything else)
- `~/.ssh/` — OpenSSH hardcodes this path

---

## 6. Secret Management Architecture

### 6.1 Flow

```
┌──────────────┐     op read / op inject     ┌──────────────────────┐
│  1Password   │ ──────────────────────────►  │  Ansible Template    │
│  (vault)     │                              │  (Jinja2)            │
└──────────────┘                              └──────┬───────────────┘
                                                     │
                                                     ▼
                                              ┌──────────────────────┐
                                              │  Config file on disk │
                                              │  (e.g., graphite     │
                                              │   user_config)       │
                                              └──────────────────────┘
```

### 6.2 Ansible integration

Use the `community.general.onepassword` lookup plugin in roles that need secrets:

```yaml
# Example: roles/graphite/tasks/main.yml
- name: Deploy Graphite user_config
  ansible.builtin.template:
    src: user_config.j2
    dest: "{{ xdg_config_home }}/graphite/user_config"
    mode: "0600"
  vars:
    work_token: "{{ lookup('community.general.onepassword', 'Graphite Work', field='credential') }}"
    personal_token: "{{ lookup('community.general.onepassword', 'Graphite Personal', field='credential') }}"
```

### 6.3 Runtime secrets (env vars via mise)

For per-project env vars like `GH_TOKEN`, mise supports 1Password references natively using templates:

```toml
# Example: ~/Projects/work/some-repo/.mise.toml
[env]
GH_TOKEN = "{{ exec 'op read op://Work/GitHub-Token/credential --no-newline' }}"
GRAPHITE_PROFILE = "work"
```

This means the token is resolved at shell-init time by mise calling `op read`. The token is never written to disk in plaintext.

### 6.4 Failure handling

If `op` is not authenticated, the Ansible playbook MUST fail early with a clear message:

```yaml
# roles/onepassword/tasks/main.yml
- name: Verify 1Password CLI is authenticated
  ansible.builtin.command: op account list
  register: op_check
  changed_when: false
  failed_when: op_check.rc != 0

- name: Fail with helpful message if not authenticated
  ansible.builtin.fail:
    msg: "1Password CLI is not signed in. Run 'eval $(op signin)' first."
  when: op_check.rc != 0
```

---

## 7. Identity Resolution Architecture

Identity switching is the most complex subsystem. It uses a **layered approach** where each tool has its own switching mechanism, but they all converge on the same identity context.

### 7.1 Identity context sources

Two complementary mechanisms determine identity:

| Mechanism | Scope | Tools it drives |
|---|---|---|
| **Directory convention** | Automatic by path | Git (via `includeIf`), SSH (via host alias) |
| **Per-project `.mise.toml`** | Explicit per-repo | `GH_TOKEN`, `GRAPHITE_PROFILE`, MCP server env vars |

**Directory convention:**
```
~/Projects/
├── work/          # All work repos cloned here
│   └── <repo>/
└── personal/      # All personal repos cloned here (or ~/Projects root)
    └── <repo>/
```

### 7.2 Git identity switching

```
$XDG_CONFIG_HOME/git/
├── config              # Main config with includeIf directives
├── config-work         # Work identity (name, email, signing key)
└── config-personal     # Personal identity
```

```gitconfig
# config
[includeIf "gitdir:~/Projects/work/"]
    path = config-work

[includeIf "gitdir:~/Projects/personal/"]
    path = config-personal
```

### 7.3 SSH identity switching

SSH config uses host aliases to route to the correct key:

```ssh-config
# ~/.ssh/config

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Default (personal)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

Work repos are cloned with the host alias: `git clone git@github.com-work:org/repo.git`. Git's remote URL determines which key is used — no env var needed.

### 7.4 GitHub CLI identity switching

Driven entirely by `GH_TOKEN` set in per-project `.mise.toml`:

```toml
# ~/Projects/work/some-repo/.mise.toml
[env]
GH_TOKEN = "{{ exec 'op read op://Work/GitHub-Token/credential --no-newline' }}"
```

When `gh` runs inside this directory, mise injects the correct token.

### 7.5 Graphite CLI identity switching

**Provisioning time (Ansible):** The Graphite role templates `user_config` with both profiles, tokens pulled from 1Password:

```json
{
  "alternativeProfiles": [
    { "name": "work", "authToken": "<injected from 1Password>" },
    { "name": "personal", "authToken": "<injected from 1Password>" }
  ]
}
```

**Runtime:** Driven by `GRAPHITE_PROFILE` in per-project `.mise.toml`:

```toml
# ~/Projects/work/some-repo/.mise.toml
[env]
GRAPHITE_PROFILE = "work"
```

### 7.6 MCP server identity switching

Claude Code supports project-level MCP configuration via `.mcp.json` at the project root. MCP servers read credentials from environment variables, which mise sets per-project.

**Pattern:**

```
.mise.toml          sets env vars (LINEAR_API_KEY, FIGMA_TOKEN, etc.)
    ↓
.mcp.json           references those env vars in server config
    ↓
Claude Code         reads .mcp.json, starts MCP servers with injected env
```

**Example `.mcp.json` for a work project:**

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@linear/mcp-server"],
      "env": {
        "LINEAR_API_KEY": "${LINEAR_API_KEY}"
      }
    }
  }
}
```

**Corresponding `.mise.toml`:**

```toml
[env]
LINEAR_API_KEY = "{{ exec 'op read op://Work/Linear-API-Key/credential --no-newline' }}"
FIGMA_TOKEN = "{{ exec 'op read op://Work/Figma-Token/credential --no-newline' }}"
```

**Design decision:** The dotfiles repo does NOT ship `.mcp.json` or `.mise.toml` into individual projects. Instead, the Claude Code role can install a **global/user-level** MCP config with default (personal) credentials, and projects that need work credentials override via their own `.mcp.json` + `.mise.toml`. The dotfiles repo provides documentation and template examples.

### 7.7 Unified identity — summary

For a work project, the complete `.mise.toml` looks like:

```toml
[env]
GH_TOKEN = "{{ exec 'op read op://Work/GitHub-Token/credential --no-newline' }}"
GRAPHITE_PROFILE = "work"
LINEAR_API_KEY = "{{ exec 'op read op://Work/Linear-API-Key/credential --no-newline' }}"
FIGMA_TOKEN = "{{ exec 'op read op://Work/Figma-Token/credential --no-newline' }}"
```

Git identity is handled automatically by the directory convention (`~/Projects/work/`). SSH identity is handled by the remote URL host alias. Everything else is driven by mise env vars sourced from 1Password at runtime.

---

## 8. SSH Key Provisioning

### 8.1 Design decision: keys on disk vs. 1Password SSH agent

1Password offers a built-in SSH agent that serves keys without writing them to disk. However, this design uses **keys on disk provisioned by Ansible** because:
- It works with all SSH clients without special agent configuration.
- It is simpler to debug and reason about.
- The keys are still sourced from 1Password — they are never in the dotfiles repo.

**Alternative:** If you later prefer the 1Password SSH agent, the `ssh` role can be swapped to configure `IdentityAgent` instead. The role boundary stays the same.

### 8.2 Provisioning flow

```yaml
# roles/ssh/tasks/main.yml
- name: Ensure ~/.ssh directory exists
  ansible.builtin.file:
    path: "{{ ansible_env.HOME }}/.ssh"
    state: directory
    mode: "0700"

- name: Provision SSH private key (work)
  ansible.builtin.copy:
    content: "{{ lookup('community.general.onepassword', 'SSH Key Work', field='private key') }}"
    dest: "{{ ansible_env.HOME }}/.ssh/id_ed25519_work"
    mode: "0600"

- name: Provision SSH public key (work)
  ansible.builtin.copy:
    content: "{{ lookup('community.general.onepassword', 'SSH Key Work', field='public key') }}"
    dest: "{{ ansible_env.HOME }}/.ssh/id_ed25519_work.pub"
    mode: "0644"

# Repeat for personal key...

- name: Deploy SSH config
  ansible.builtin.template:
    src: config.j2
    dest: "{{ ansible_env.HOME }}/.ssh/config"
    mode: "0600"
```

---

## 9. Font Provisioning

### 9.1 Flow

```
1Password (SSH key) → SSH agent → git clone (private repo) → copy .ttf/.otf → ~/Library/Fonts/
```

### 9.2 Role design

```yaml
# roles/fonts/defaults/main.yml
berkeley_mono_repo: "git@github.com:<user>/berkeley-mono.git"
berkeley_mono_clone_path: "{{ xdg_data_home }}/fonts/berkeley-mono"
font_install_path: "{{ ansible_env.HOME }}/Library/Fonts"
```

```yaml
# roles/fonts/tasks/main.yml
- name: Clone Berkeley Mono repository
  ansible.builtin.git:
    repo: "{{ berkeley_mono_repo }}"
    dest: "{{ berkeley_mono_clone_path }}"
    version: main
    accept_hostkey: true

- name: Find font files
  ansible.builtin.find:
    paths: "{{ berkeley_mono_clone_path }}"
    patterns: "*.ttf,*.otf"
    recurse: true
  register: font_files

- name: Install fonts to ~/Library/Fonts
  ansible.builtin.copy:
    src: "{{ item.path }}"
    dest: "{{ font_install_path }}/{{ item.path | basename }}"
    mode: "0644"
  loop: "{{ font_files.files }}"
```

---

## 10. Starship Prompt Design

Minimal prompt matching the spec: `user@host:working_dir [git_branch_name]`

```toml
# roles/starship/files/starship.toml
format = "$username@$hostname:$directory $git_branch$line_break$character"

[username]
show_always = true
format = "[$user](bold)"

[hostname]
ssh_only = false
format = "[$hostname](bold)"

[directory]
truncation_length = 0
truncate_to_repo = false
format = "[$path]($style)"

[git_branch]
format = "[\\[$branch\\]]($style) "

[character]
success_symbol = "[\\$](bold)"
error_symbol = "[\\$](bold red)"

# Disable all other modules
[aws]
disabled = true
[gcloud]
disabled = true
[nodejs]
disabled = true
[python]
disabled = true
[rust]
disabled = true
[golang]
disabled = true
[package]
disabled = true
[docker_context]
disabled = true
[cmd_duration]
disabled = true
```

---

## 11. Makefile Interface

```makefile
.DEFAULT_GOAL := help

help:            ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-15s %s\n", $$1, $$2}'

bootstrap:       ## Full setup from scratch (fresh machine)
	./bootstrap.sh

apply:           ## Run full Ansible playbook
	ansible-playbook playbook.yml

apply-%:         ## Run a single role (e.g., make apply-git)
	ansible-playbook playbook.yml -t $*

lint:            ## Lint all roles with ansible-lint
	ansible-lint playbook.yml
```

---

## 12. Key Design Decisions Summary

| # | Decision | Rationale |
|---|---|---|
| D1 | Ansible roles with NO `meta/main.yml` dependencies | Roles stay decoupled; playbook controls order. |
| D2 | 1Password lookup plugin for provisioning-time secrets | Secrets never touch the repo. Ansible templates inject them. |
| D3 | mise `exec` templates for runtime secrets | Tokens resolved at shell-init, never on disk in plaintext. |
| D4 | Directory convention (`~/Projects/work/` vs `personal/`) for Git/SSH identity | Automatic, no per-repo config needed for Git identity. |
| D5 | Per-project `.mise.toml` for tool-token identity (gh, graphite, MCP) | Explicit, flexible, works with 1Password `op read`. |
| D6 | SSH keys on disk (provisioned from 1Password) | Simpler, universal compatibility. Can swap to 1Password SSH agent later. |
| D7 | `~/.zshenv` is the only allowed root-level dotfile | Unavoidable — Zsh needs it to find `ZDOTDIR`. |
| D8 | `~/.ssh/` stays at default path | OpenSSH hardcodes it. Accepted exception to XDG. |
| D9 | Each role installs its own Homebrew packages | Self-contained bricks. No shared package lists. |
| D10 | Global MCP config for defaults, project `.mcp.json` for overrides | Personal identity is the safe default; work projects opt-in. |

---

## 13. 1Password Vault Organization (Recommended)

To keep `op read` references clean and predictable:

```
Vault: Dotfiles
├── SSH Key - Work              (fields: private key, public key)
├── SSH Key - Personal          (fields: private key, public key)
├── GitHub Token - Work         (field: credential)
├── GitHub Token - Personal     (field: credential)
├── Graphite Token - Work       (field: credential)
├── Graphite Token - Personal   (field: credential)
├── Linear API Key - Work       (field: credential)
├── Linear API Key - Personal   (field: credential)
├── Figma Token - Work          (field: credential)
└── Figma Token - Personal      (field: credential)
```

This gives predictable `op://Dotfiles/<Item>/<Field>` URIs.

---

## 14. What the Dotfiles Repo Does NOT Do

| Out of scope | Why |
|---|---|
| Ship `.mise.toml` into individual projects | Per-project config is owned by the project, not the dotfiles. The dotfiles provide docs/templates. |
| Manage macOS system preferences (Dock, Finder, etc.) | Fragile, breaks across macOS versions. Can be added as a separate role later if desired. |
| Install Xcode.app | Only Xcode Command Line Tools are needed. Full Xcode is a manual install. |
| Manage 1Password vault contents | The dotfiles consume secrets from 1Password; they don't create or manage the vault items themselves. |
