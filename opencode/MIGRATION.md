# Claude Code → OpenCode Migration Plan

## What's Being Migrated

| Claude Code | OpenCode | Status |
|-------------|----------|--------|
| `~/.config/opencode/opencode.json` | Same path, expanded | Done |
| `.claude/CLAUDE.md` | `AGENTS.md` (project root) | Done |
| `.claude/rules/*.md` | `.opencode/rules/*.md` + `instructions` field | Done |
| `.claude/settings.json` permissions | `opencode.json` `permission` field | Done |
| `.claude/settings.json` hooks | `opencode.json` `formatter` field | Done |
| `.claude/settings.local.json` MCP | `opencode.json` `mcp` field | Done |
| `.claude/skills/bug/` | `.opencode/commands/bug.md` | Done |
| `.claude/skills/cycle/` | `.opencode/commands/cycle.md` | Done |
| `.claude/skills/issue/` | `.opencode/commands/issue.md` | Done |
| `.claude/skills/ship/` | `.opencode/commands/ship.md` | Done |
| `.claude/skills/start/` | `.opencode/commands/start.md` | Done |
| `.claude/skills/issue/references/` | `.opencode/skills/issue/references/` | Done |

## Per-Project Zen Auth

Single env var `OPENCODE_API_KEY`, set per project via `.mise.local.toml`.

- Global config (`~/.config/opencode/opencode.json`): references `{env:OPENCODE_API_KEY}`
- Work projects (skydeo): set in `.mise.local.toml` with work Zen key
- Personal projects: set in `.mise.local.toml` with personal Zen key

## Multi-Account MCP (Linear)

Use different server names per account so OAuth tokens stay separate:

- Work projects: `"linear-work"` in `opencode.json`
- Personal projects: `"linear-personal"` in `opencode.json`

Authenticate each independently: `opencode mcp auth linear-work` / `opencode mcp auth linear-personal`. Tokens stored separately in `~/.local/share/opencode/mcp-auth.json`.

Tool names are prefixed by server name (e.g. `linear-work_get_issue`). Command prompts use generic references so the AI resolves the correct prefix.

## Key Differences

| Concept | Claude Code | OpenCode |
|---------|-------------|----------|
| Project rules file | `CLAUDE.md` | `AGENTS.md` (reads CLAUDE.md as fallback) |
| Skills/commands dir | `.claude/skills/` | `.opencode/commands/` (markdown files) |
| Rule files | `.claude/rules/` | `.opencode/rules/` + `instructions` in config |
| Hooks | `settings.json` hooks | `formatter` config or plugins |
| Config format | Multiple JSON files | Single `opencode.json` |
| Plan mode toggle | `Shift+Tab` | `Tab` |
| Model selection | Set in config | Manual via `<leader>m` |
| Env var substitution | Not supported | `{env:VAR_NAME}` in config values |
| File injection in commands | Not supported | `@path/to/file` in command templates |
| Shell output in commands | `` !`cmd` `` | Same syntax |

## File Structure (Skydeo)

```
~/Projects/skydeo/
  opencode.json                  # project config (permissions, MCP linear-work, formatter)
  AGENTS.md                      # philosophy
  .opencode/
    rules/
      biome.md                   # Ultracite code standards
      workflow.md                # workflow rules
    commands/
      bug.md                     # /bug — triage + investigate
      cycle.md                   # /cycle — plan/review/cooldown
      issue.md                   # /issue — create Linear issues
      ship.md                    # /ship — validate + PR
      start.md                   # /start — begin work on issue
    skills/
      issue/
        references/
          decompose.md           # sub-task decomposition
          project.md             # project-scope work
```

## Verification

1. `cd ~/Projects/skydeo && opencode` — launches with project config
2. Type `/` — all 5 commands visible in autocomplete
3. `/start SWE-XXX` — Linear MCP fetches issue, gt syncs trunk
4. `/ship` — validates code, creates Graphite branch + PR
5. `/issue description` — explores code, creates Linear issue
6. Edit a `.ts` file — ultracite formatter auto-runs
7. Confirm Zen work account active (provider display in TUI)
8. `cd ~/personal-project && opencode` — uses personal Zen key (global fallback)
