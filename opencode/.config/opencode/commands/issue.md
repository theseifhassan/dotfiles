---
description: Create a structured Linear issue from a description
model: opencode/claude-sonnet-4-5
---

# Create Linear Issue

Parse `$ARGUMENTS` as the work description. Ask 1-2 clarifying questions only if genuinely ambiguous.

## Process

1. Determine type, initial estimate per workflow rules.
2. **Explore codebase.** Identify what this work touches before writing the spec:
   - Search for relevant files, modules, and packages using Glob and Grep.
   - Read key files to understand existing patterns, data models, and API surface.
   - Map the impact: which files change, which API routes are affected, which packages are touched, what existing tests cover this area.
   - Note architectural constraints, shared dependencies, or migration concerns.
   - Revise the estimate if the codebase exploration reveals more (or less) complexity than initially assumed.
   - Summarize findings — these feed directly into the Spec and Acceptance Criteria.
3. Search for duplicates via `list_issues` with `query: "<keywords>"` and `team: "Software Engineering"`. Flag if found.
4. **Plan due date.** Gather context to derive a realistic due date:
   - Resolve team UUID via `get_team` with `query: "Software Engineering"`.
   - Fetch current cycle via `list_cycles` with `type: "current"` — note start/end dates and remaining capacity.
   - Fetch current cycle issues via `list_issues` with `cycle: "<cycle-id>"` — sum estimates by status to gauge remaining load.
   - Check `list_cycles` with `type: "previous"` for velocity baseline (completed estimate points per cycle).
   - If the work has a project, fetch it via `get_project` with `includeMilestones: true` for milestone target dates.
   - Derive the due date: given the estimate, current load, velocity, dependency chain, and cycle boundaries, when would this work realistically be completed? Align to cycle end dates where practical (work planned for a cycle should be due by cycle end). Present the reasoning alongside the draft.
5. **Route by scope:**

   | Scope | Route |
   |-------|-------|
   | **XS–M** (1-3) | Create directly — continue below |
   | **L** (5) | Read @.opencode/skills/issue/references/decompose.md, create parent + sub-issues |
   | **XL / multi-cycle** | Read @.opencode/skills/issue/references/project.md, create project + parent issues + sub-issues |

6. Draft the issue and present for approval:

   **Title:** `type(scope): description`

   **Body:**
   ```
   ## Context
   Why this needs to happen.

   ## Affected Areas
   Files, packages, routes, and patterns touched (from codebase exploration).

   ## Spec
   What exactly needs to change — grounded in the codebase findings.

   ## Acceptance Criteria
   - [ ] Verifiable criterion 1
   - [ ] Verifiable criterion 2

   ## Validation
   pnpm typecheck && pnpm check
   ```

   **Metadata:** label, estimate, due date (with reasoning), assignee, project (if multi-cycle), relations (if dependencies exist).

7. Wait for approval — never create without sign-off.
8. Create via `create_issue`:
   - `title`, `team: "Software Engineering"`, `description`
   - `labels: ["<type>"]` (substring match, e.g. `"feat"`)
   - `estimate: <fibonacci value>`
   - `dueDate: "<ISO date>"` (from planning analysis in step 4)
   - `assignee` (ask or use `"me"`)
   - `state: "Backlog"`
   - `project: "<name>"` if applicable
   - `blocks` / `blockedBy` if dependencies exist
9. Return issue identifier and URL from response.

## Urgency

All new issues default to **Backlog**. If the engineer explicitly says "add to current cycle" or marks it as urgent:

1. Fetch the current cycle via `list_cycles` with `type: "current"`.
2. List current cycle issues via `list_issues` with `cycle: "<cycle-id>"` to show current load.
3. **Swap rule:** every mid-cycle addition requires deferring an issue of equal or greater estimate. Present the current cycle contents and ask what to defer.
4. On approval: create the issue with `state: "Todo"` and `cycle: "<cycle-id>"`. Defer the swapped issue via `update_issue` with `cycle: null`, `state: "Backlog"`.

Skip the swap rule only for Critical bugs (priority 1) — those get added without displacement. High-priority (priority 2) still requires a swap.

## Constraints

- Keep acceptance criteria verifiable — no "works correctly."
- Keep titles clean: no IDs, no markdown. Concise and scannable.
