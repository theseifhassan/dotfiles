# Identity Switching

This system manages multiple identities (work and personal) across Git, SSH, GitHub CLI, Graphite CLI, and MCP servers. Two complementary mechanisms handle identity resolution:

| Mechanism | Scope | Tools |
|---|---|---|
| **Directory convention** | Automatic by path | Git (`includeIf`), SSH (host alias in remote URL) |
| **Per-project `.mise.toml`** | Explicit per-repo | `GH_TOKEN`, `GRAPHITE_PROFILE`, `LINEAR_API_KEY`, `FIGMA_TOKEN` |

When no project-level override exists, most tools default to personal credentials. Tokens are resolved at shell-init time by mise calling `op read` — they are never written to disk in plaintext.

---

## Directory Convention

All repositories live under `~/Projects/`, split by identity:

```
~/Projects/
├── work/          # All work repositories
│   └── <repo>/
└── personal/      # All personal repositories
    └── <repo>/
```

---

## Git Identity Switching

Git uses [`includeIf`](https://git-scm.com/docs/git-config#_conditional_includes) directives to load the correct identity based on the repository's path.

**Config files:**

```
~/.config/git/
├── config              # Main config with includeIf directives
├── config-work         # Work identity (name, email, signing key)
└── config-personal     # Personal identity
```

**How it works:**

The main `~/.config/git/config` contains:

```gitconfig
[includeIf "gitdir/i:~/Projects/work/"]
    path = ~/.config/git/config-work

[includeIf "gitdir/i:~/Projects/personal/"]
    path = ~/.config/git/config-personal
```

When you run `git commit` inside `~/Projects/work/some-repo/`, Git automatically loads `config-work` which sets your work name, email, and signing key. The `gitdir/i` variant is case-insensitive.

There is **no default `[user]` block** — repos outside of `~/Projects/work/` or `~/Projects/personal/` will fail to commit until you explicitly configure an identity. This is intentional to prevent accidental commits with the wrong identity.

---

## SSH Host Aliases

SSH config uses host aliases to route to the correct key based on the remote URL.

**Config:**

```
~/.ssh/
├── config                     # Host aliases
├── id_ed25519_work            # Work SSH key (from 1Password)
├── id_ed25519_personal        # Personal SSH key (from 1Password)
└── id_ed25519_macbook         # Machine key (from 1Password)
```

**SSH config entries:**

```ssh-config
Host work.github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

Host *
    AddKeysToAgent yes
    HashKnownHosts yes
    IdentityFile ~/.ssh/id_ed25519_macbook
```

**Cloning work repos:**

```bash
# Work — use the work.github.com host alias
cd ~/Projects/work
git clone git@work.github.com:org/repo.git

# Personal — use github.com directly
cd ~/Projects/personal
git clone git@github.com:user/repo.git
```

The host alias in the remote URL determines which SSH key is used.

---

## GitHub CLI

The `gh` CLI reads its authentication token from the `GH_TOKEN` environment variable. Identity switching is handled by setting this variable per-project via `.mise.toml`.

No global GitHub token is configured — each project must provide its own via `.mise.toml` (see [Templates](#template-misetoml) below).

---

## Graphite CLI

Graphite uses a two-layer approach:

1. **Provisioning time:** The Ansible `graphite` role templates `~/.config/graphite/user_config` with both work and personal profile tokens (fetched from 1Password).
2. **Runtime:** The `GRAPHITE_PROFILE` environment variable selects which profile to use.

The default profile (first in the config) is work. Personal projects override by setting `GRAPHITE_PROFILE=personal` in their `.mise.toml`.

---

## MCP Servers (Claude Code)

MCP server credentials are configured at two levels:

### Global defaults (personal)

The Ansible `claude-code` role deploys:

- **`~/.claude.json`** — MCP server definitions (Linear, Figma) that reference environment variables in their auth headers.
- **`~/.config/mise/conf.d/mcp.toml`** — Default (personal) credential env vars resolved via `op read` at shell init.

```toml
# ~/.config/mise/conf.d/mcp.toml (deployed by Ansible)
[env]
LINEAR_API_KEY = "{{ exec(command='op read \"op://Dotfiles/Linear API Key - Personal/credential\" --no-newline') }}"
FIGMA_TOKEN = "{{ exec(command='op read \"op://Dotfiles/Figma Token - Personal/credential\" --no-newline') }}"
GREPTILE_TOKEN = "{{ exec(command='op read \"op://Dotfiles/Greptile Token - Personal/credential\" --no-newline') }}"
```

### Project overrides (work)

Work projects override the global defaults by setting the same env vars in their `.mise.toml` to point at work credentials. Project-level values take precedence.

See [Templates](#template-misetoml) below.

---

## Templates

### Template: `.mise.toml`

Copy this into the root of a work project to switch all tools to the work identity:

```toml
# .mise.toml — work project identity
[env]
# GitHub CLI
GH_TOKEN = "{{ exec(command='op read \"op://Dotfiles/GitHub Token - Work/credential\" --no-newline') }}"

# Graphite CLI
GRAPHITE_PROFILE = "work"

# MCP servers (overrides global personal defaults)
LINEAR_API_KEY = "{{ exec(command='op read \"op://Dotfiles/Linear API Key - Work/credential\" --no-newline') }}"
FIGMA_TOKEN = "{{ exec(command='op read \"op://Dotfiles/Figma Token - Work/credential\" --no-newline') }}"
GREPTILE_TOKEN = "{{ exec(command='op read \"op://Dotfiles/Greptile Token - Work/credential\" --no-newline') }}"
```

### Template: `.mcp.json`

If a work project needs **additional** MCP servers beyond the global ones, add a `.mcp.json` at the project root:

```json
{
  "mcpServers": {
    "project-specific-server": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"],
      "env": {
        "API_KEY": "${EXAMPLE_API_KEY}"
      }
    }
  }
}
```

Then add the corresponding env var to the project's `.mise.toml`:

```toml
[env]
EXAMPLE_API_KEY = "{{ exec(command='op read \"op://Dotfiles/Example API Key - Work/credential\" --no-newline') }}"
```

Global MCP servers (Linear, Figma) are already in `~/.claude.json` — a project `.mcp.json` is only needed for additional servers.

---

## Adding a New Dual-Account Service

To add identity switching for a new service (e.g., a new MCP server):

1. **Store credentials in 1Password.** Create two items in the `Dotfiles` vault following the naming convention:

   ```
   <Service> Token - Work      (field: credential)
   <Service> Token - Personal   (field: credential)
   ```

2. **Add 1Password references to `group_vars/all.yml`:**

   ```yaml
   op_<service>_tokens:
     work:
       item: "<Service> Token - Work"
       field: "credential"
     personal:
       item: "<Service> Token - Personal"
       field: "credential"
   ```

3. **Set the global default (personal) in the claude-code role.** In `roles/claude-code/tasks/main.yml`, find the "Deploy MCP credential env vars to mise conf.d" task and add a line to its `content:` block. The line must use Ansible Jinja2 escaping (matching the existing entries):

   ```yaml
   <SERVICE>_TOKEN = "{{ '{{' }} exec(command='op read \"op://{{ op_vault }}/{{ op_<service>_tokens.personal.item }}/{{ op_<service>_tokens.personal.field }}\" --no-newline') {{ '}}' }}"
   ```

   This renders to mise Tera syntax in the deployed `~/.config/mise/conf.d/mcp.toml`.

4. **Add the MCP server definition.** In the same file, find the "Merge MCP servers into ~/.claude.json" task and add to its `managed_mcp_servers` vars:

   ```yaml
   <service>:
     type: http
     url: "https://mcp.<service>.com/mcp"
     headers:
       Authorization: "Bearer ${<SERVICE>_TOKEN}"
   ```

5. **Override in work projects.** Add the work credential to the project's `.mise.toml`:

   ```toml
   [env]
   <SERVICE>_TOKEN = "{{ exec(command='op read \"op://Dotfiles/<Service> Token - Work/credential\" --no-newline') }}"
   ```

6. **Run `make apply-claude-code`** to deploy the updated global config.

---

## Default Fallback

When no project-level `.mise.toml` is present:

| Tool | Fallback behavior |
|---|---|
| **Git** | No `[user]` block — commits will fail (intentional safety net) |
| **SSH** | `github.com` routes to personal key |
| **GitHub CLI** | No `GH_TOKEN` set — `gh` prompts for auth |
| **Graphite** | Default profile in `user_config` is work |
| **MCP servers** | Global `conf.d/mcp.toml` provides personal tokens |

Git has **no default identity** to prevent accidental commits with the wrong name/email. Graphite defaults to the work profile (first entry in `identity_profiles`). SSH and MCP servers default to personal credentials.
