# Dotfiles

Ansible-based macOS dotfiles with dual-identity (work/personal) support.

## Quick Start

```bash
# Fresh machine
./bootstrap.sh

# Re-run (all roles)
ansible-playbook playbook.yml --ask-vault-pass

# Single role
ansible-playbook playbook.yml -t claude-code --ask-vault-pass
```

## Roles

| Group | Role | What it does |
|-------|------|-------------|
| **Identity** | ssh | SSH keys + host aliases for work/personal |
| | git | Git config with `includeIf` identity switching |
| | gh | GitHub CLI |
| | graphite | Graphite CLI with dual-profile tokens |
| **Shell** | zsh | Zsh config under `ZDOTDIR` |
| | starship | Minimal prompt |
| | mise | Per-project tool/env management |
| **Editors & Terminal** | ghostty | Terminal emulator |
| | tmux | Terminal multiplexer |
| | neovim | Neovim |
| | claude-code | Claude Code + MCP servers + skills |
| | zed | Zed editor |
| **Desktop** | aerospace | Tiling window manager |
| | apps | Chrome, Figma, Linear, Slack, Gather |
| **Fonts** | fonts | Berkeley Mono from private repo |

Foundation roles (`xdg`, `homebrew`) are pulled in automatically via role dependencies.

## Identity Switching

Two mechanisms handle work/personal identity:

| Mechanism | Scope | Tools |
|-----------|-------|-------|
| **Directory convention** | Automatic by path | Git (`includeIf`), SSH (host alias) |
| **Per-project `.mise.toml`** | Explicit per-repo | `GH_TOKEN`, `GRAPHITE_PROFILE`, `LINEAR_TOKEN`, `GREPTILE_TOKEN` |
| **Per-project `.mcp.json`** | Explicit per-repo | OAuth-only MCP servers (e.g., Figma) |

All repos live under `~/Projects/work/` or `~/Projects/personal/`. Git and SSH switch automatically by path. Everything else uses per-project `.mise.toml` for env vars and `.mcp.json` for OAuth MCP servers with identity-suffixed names (e.g., `figma-personal`, `figma-work`).

## Secrets

Secrets are managed via Ansible Vault (`group_vars/all/vault.yml`) for provisioning-time values and 1Password (`op read`) via mise for runtime values. No plaintext secrets on disk.

## Claude Code Setup

The `claude-code` role is plugin-free. It manages:

- **MCP servers** in `~/.claude.json`: Context7 (stdio), Linear (Bearer token), Greptile (Bearer token)
- **Skills** via `npx skills add`: skill-creator, implement-design, create-design-system-rules, code-connect-components
- **Settings** with auto-allowed MCP tools (no permission prompts)

MCP credentials (`LINEAR_TOKEN`, `GREPTILE_TOKEN`) are set per-project via `.mise.toml`. OAuth-only servers (Figma) use project-scoped `.mcp.json` with identity-suffixed names.
