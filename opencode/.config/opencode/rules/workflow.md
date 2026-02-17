# Workflow Rules

These rules are auto-loaded into every OpenCode session. They govern how you work in this codebase.

## Principles

1. Every piece of work has a Linear issue. No issue, no work.
2. Small PRs, always. One concern per PR. Stack with Graphite when changes build on each other.
3. Validate before you commit. `pnpm typecheck && pnpm check` is the minimum bar.
4. The Linear issue is the spec. No separate spec documents.

## Naming Conventions

| What | Format | Example |
|------|--------|---------|
| Issue title | `type(scope): description` | `feat(auth): add login form` |
| Branch | `type/short-description` | `feat/auth-login-form` |
| Commit | `type(scope): description [SWE-XXX]` | `feat(auth): add login form [SWE-123]` |
| PR title | Same as commit | Auto-set by Graphite |

Types: `feat`, `fix`, `refactor`, `chore`, `spike`

No Linear IDs in branch names. IDs live in commit messages only.

## Sizing

| Estimate | Size | Meaning |
|----------|------|---------|
| 1 | XS | Trivial, one file |
| 2 | S | Small, few files |
| 3 | M | Moderate, multiple files |
| 5 | L | Large, needs sub-tasks |
| N/A | XL | Must decompose first |

## Sized Behavior

- **XS/S (1-2):** Implement directly. No ceremony.
- **M (3):** Confirm approach before coding. Ask if spec has gaps.
- **L (5):** Enter Plan Mode (`Tab`). Design approach, present plan, get approval before implementing.
- **XL:** Do not implement. Use `/issue` — it will decompose automatically.

## The Work Loop

```
/start SWE-XXX → implement on trunk/stack tip → validate → /ship → review → merge → gt sync
```

1. `/start` reads the spec, syncs trunk, moves issue to In Progress
2. Implement the change
3. Validate: `pnpm typecheck && pnpm check`
4. `/ship` creates a Graphite branch, submits the PR
5. Review (self for XS/S, peer for M+) → merge
6. GitHub integration auto-moves issue to Done on merge

## Graphite Flow

Work first, branch second:
```bash
gt sync                                                    # Sync trunk
# ... implement ...
gt create -am "type(scope): desc [SWE-XXX]" type/slug      # Branch + commit
gt submit                                                  # Push + create PR
```

Modify existing branch: `gt modify --all`
Navigate stack: `gt up`, `gt down`, `gt top`, `gt bottom`, `gt log short`
Merge stacks bottom-to-top. Run `gt sync` after merging.

## Validation

Always run before committing:
```bash
pnpm typecheck && pnpm check
```

If tests exist: `pnpm test`
Scoped during development: `pnpm --filter @scope/pkg typecheck`

## Commit Discipline

- Each commit must pass validation independently.
- Follow the naming convention exactly.
- Do not bundle unrelated changes.
- Do not modify code outside the current issue's scope.

## Getting Stuck

3 distinct approaches, then stop. Write a clear problem report with what you tried. Never loop on the same approach.

## Monorepo Awareness

- Changes in shared packages affect consumers. Always validate at root.
- Build order is automatic via Turbo (`^build` dependencies).
- Scope for speed during development, root-level before committing.

## Mid-Cycle Changes

All new work lands in **Backlog** by default. Mid-cycle additions require the **swap rule**:
- Every addition requires deferring an issue of equal or greater estimate from the current cycle.
- **Critical bugs (priority 1)** are the only exception — they skip the swap rule.
- **High-priority bugs (priority 2)** trigger the swap rule automatically via `/bug`.
- **Normal/Low (priority 3-4)** stay in Backlog for the next `/cycle plan`.

## Timing

| Command | When |
|---------|------|
| `/issue`, `/bug` | Anytime — creates work in Backlog (with optional urgency routing) |
| `/start`, `/ship` | During cycle — implementation and submission |
| `/cycle plan` | Cycle start — Monday morning of a new cycle |
| `/cycle review` | Mid-cycle — enforces swap rule |
| `/cycle cooldown` | Cycle end — before a cooldown week |

## Available Commands

```
/issue      — Create issues, decompose sub-tasks, or set up projects
/bug        — Capture, triage, investigate, and route by urgency
/start      — Begin work on an issue
/ship       — Validate, branch, submit PR
/cycle      — Plan cycles, review progress, plan cooldown
```
