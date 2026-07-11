# CLAUDE.md

Project guidance for Claude Code. The workflow-managed blocks below are owned by the SAW skills (`/saw:setup` et al.) — edit the bullets' inline parentheticals to tune policy, but leave the marker comments intact.

<!-- workflow:managed:start kind=stack -->
## SAW Stack

- tracker: github_issues (post-scope label: todo)
- vcs: graphite
- review: none (self / Claude review)
<!-- workflow:managed:end kind=stack -->

<!-- workflow:managed:start kind=shared-rules -->
# Workflow Agent Rules

Shared rules for every workflow skill. `/setup` syncs this file's content into the project's CLAUDE.md (or `AGENTS.md`) workflow-managed `kind=shared-rules` block. Re-running `/setup` updates the block in place; project rules outside it are preserved.

## Stack resolution

Skills name backends by family (`tracker` / `vcs` / `review`) via the `<!-- workflow:managed:start kind=stack -->` block in CLAUDE.md (or `AGENTS.md`). Each bullet is `family: backend`; an inline parenthetical overrides team policy (e.g. `review: greptile (iteration_cap=3)`). Halt and recommend `/setup` when the block is missing.

Discover backend-specific values (status names, team / project / repo IDs, default branch, work-item prefix) at runtime via the backend's API or local environment — never declared up front. When a team-policy choice the backend can't resolve comes up, ask once and persist the answer as an inline parenthetical on the matching `kind=stack` bullet.

**Artifacts and validation are not configured.** Artifacts always land in `<workflow-root>/artifacts/`. Validation runs whichever checks the project exposes (npm scripts, pytest, cargo, Makefile targets, language-conventional commands) at the level the skill asks for — `fast` for `/start`, `pre_ship` for `/ship`.

## Composing work-item and PR bodies

The plugin ships no markdown body templates. Bodies are composed inline at write time:

1. **Sample 3–5 recent items** of the same kind from the relevant surface (the tracker for work-item bodies; the repo's merged PRs for PR bodies). If a clear convention exists, mirror it.
2. **No convention** (or no prior items): use the canonical structure for the kind:
   - **intake** — `## Source` + `## Context`
   - **feat** — `## Problem` + `## Outcome` + `## Acceptance criteria`
   - **fix** — `## Reproduction` + `## Expected vs Actual` + `## Acceptance criteria` (add `## Root cause` when known)
   - **chore** — `## Why now` + `## Scope` + `## Definition of done`
   - **refactor** — `## Current state` + `## Target state` + `## Acceptance criteria`
   - **spike** — `## Question` + `## Deliverable` + `## Time-box`
   - **PR body** (when the review backend leaves the body to the author) — `## Summary` + `## Changes` + `## Test plan`

## Naming Formula

`<class>(<domain>): <short_imperative_description>` — conventional-commits shape, `<short_imperative_description>` capped at **6 words**; class enum: `feat | fix | chore | refactor | spike`. The 6-word cap is hard — halt and ask for a shorter description rather than truncate.

- **Branch:** `<class>(<domain>)/<work_item_id>-<short_imperative_description>`. The `<work_item_id>` segment must survive any VCS sanitization — tracker auto-linking depends on it.
- **Commit / PR title:** append the work item ID in brackets: `feat(workflow): example behavior [<work_item_id>]`.
- **PR body link signal:** at the top of the body, write the non-closing reference `Refs <work_item_id>` — never `Closes`/`Fixes`/`Resolves`. Status transitions are plugin-owned, not tracker-auto-driven; the line is preserved even when the body is otherwise owned by the review tool.

## Vocabulary

Speak in workflow terms, not vendor terms — counter the strong training defaults: **work item** (not issue/ticket), **review artifact** (not PR/MR), **work item group** (not epic/milestone).

## Write Safety

- No `--force` / `--no-verify` from automation unless the user has explicitly accepted the elevated risk.
- No `done` status transition without explicit user OK. Auto-close-on-merge by tracker integration is not a skill action.
- Artifacts are write-once. Never overwrite, append to, or otherwise edit an existing artifact file. Revisions are new files at a new path that reference the prior artifact(s) in their References section.
- No write outside the configured workflow root. Preserve user work; never revert uncommitted changes without confirmation.

## Confirmations

Never proceed past a required confirmation without an explicit answer — from the prompt in noninteractive runs, or interactively from the user. Put the recommended option first.

## No Tool Names In Plugin Source

Plugin source contains no MCP method names or CLI tool names — the agent resolves concrete tools at runtime from the backend's self-description. Maintenance rule for skill authors.

## Token Efficiency

**Reasoning-step concision.** When deliberating internally during a skill — weighing options, checking acceptance criteria, planning a diff review, ordering dependencies — aim for short reasoning drafts of about 5 words per step instead of full prose. The 5-word target is a soft preference, not a hard cap; allow longer steps when the model is genuinely stuck and prose is needed to surface the ambiguity. Apply this in `/breakdown`, `/ship`, `/start`, and most internal deliberation across the agentic loop.

- **Carve-out: `/scope`.** This rule does NOT apply during `/scope` interview deliberation. Scoping is purpose-built for open-ended branchy work — root-cause analysis, ambiguity surfacing, weighing alternatives — and concise-reasoning techniques regress on exactly these tasks (per Chain of Draft, [arXiv:2502.18600](https://arxiv.org/abs/2502.18600)). Allow full prose reasoning when running the scope interview.
- **Carve-out: user-facing artifact content.** This rule does NOT apply to slot values, work-item bodies, PR bodies, or other artifact prose. Those keep the canonical section structures defined in *Composing work-item and PR bodies* above.

**No procedural narration.** Don't announce what you're about to do ("I'll read the file then check X") and don't explain how you're doing it ("using grep with these flags") around tool calls. The user sees the tool calls and the diffs. Reserve prose for what the user can't see: decisions, judgment calls, blockers, and the end-of-turn summary.

## Plugin Versioning

Any change touching plugin source — `plugins/saw/**` (skills, references, defaults/templates, manifest) — must bump the version. Repo-root-only changes (README, top-level docs) are exempt.

- Bump **both** manifests to the **same** value: `plugins/saw/.claude-plugin/plugin.json` and root `package.json`. Both must differ from the merge base and equal each other; a one-sided or mismatched bump fails.
- Tier by impact — **patch**: doc/prose fixes, skill-text bug fixes, behavior-neutral rule wording. **minor**: new skill, option, registry op, readiness check, defaults template, or any added behavior. **major**: breaking schema change, skill removal, op or slash-command rename/removal.
- One bump per coherent change, on the stack tip; intermediate branches in the stack are exempt. A stack needing more than one bump is conflating changes — split it.
<!-- workflow:managed:end kind=shared-rules -->
