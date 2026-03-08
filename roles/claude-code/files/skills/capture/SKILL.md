---
name: capture
description: Capture work from a plain English description. Classifies type (feat/fix/chore/refactor/spike), analyzes the codebase for scope, and creates Linear issues — single, decomposed, or full project. Use this skill whenever someone describes work to be done, reports a bug, requests a feature, proposes a refactor, or mentions any task that should be tracked. Triggers on "we need to", "can you create an issue", "let's track", "there's a bug", "something is broken", "we should refactor", "not working", "add support for", or any work/problem description.
argument-hint: [work description]
allowed-tools: mcp__linear, Read, Grep, Glob, Agent
---

# Capture Work

Parse `$ARGUMENTS` as the work description. Ask 1-2 clarifying questions only if genuinely ambiguous.

## Phase 1: Classify

Determine the category from the description:

| Category | Signal |
|----------|--------|
| `feat` | New functionality, capability, feature request |
| `fix` | Something broken, bug report, error, regression |
| `chore` | Maintenance — deps, config, CI, tooling |
| `refactor` | Code restructuring without behavior change |
| `spike` | Time-boxed research or exploration |

For `fix`: also assess severity:
- **Critical** — Production down, data loss, security vulnerability
- **High** — Core feature broken, workaround exists
- **Normal** — Non-blocking issue, degraded experience
- **Low** — Cosmetic, rare edge case

### Fix: Create Triage Issue Immediately

Bugs need a tracking record before investigation begins. When classified as `fix`, create a triage issue right away:
- `title: "fix(scope): description — investigating"`
- `team: "Software Engineering"`, `state: "Triage"`, `labels: ["fix"]`
- `priority`: 1 (Critical), 2 (High), 3 (Normal), 4 (Low)
- `description`: raw report + any clarifying info

Save the issue identifier — you will update this same issue after analysis. NEVER CREATE A SECOND ISSUE FOR THE SAME BUG.

## Phase 2: Analyze

Launch two subagents **in parallel**. This keeps the main context clean — only their summaries return.

### Subagent 1: Codebase Analysis

Launch an **Explore** subagent (`subagent_type: "Explore"`) to analyze codebase impact. Include the work description in the prompt and instruct it to:

- Search for relevant files, modules, and packages using Glob and Grep
- Read key files to understand existing patterns, data models, and API surface
- Map the impact: which files change, which API routes are affected, which packages are touched, what existing tests cover this area
- Note architectural constraints, shared dependencies, or migration concerns
- For `fix`: trace the code path where the bug likely occurs, check recent changes

Instruct the subagent to return a structured report:
```
## Affected Areas
- Files: [paths]
- Packages: [names]
- APIs/Routes: [list]

## Complexity Signals
- Cross-cutting concerns: [yes/no + details]
- New patterns needed: [yes/no + details]
- Migration required: [yes/no + details]
- Test coverage: [existing tests, gaps]

## Scope Assessment
- Estimated files to change: [count]
- Complexity: [low / medium / high / very high]
- Suggested estimate: [1 / 2 / 3 / 5 / 8+]
- Rationale: [why this estimate]
```

### Subagent 2: Linear Context

Launch a **general-purpose** subagent to gather planning context from Linear. Instruct it to:

1. Search for duplicate issues via `list_issues` with `query: "<keywords>"` and `team: "Software Engineering"`
2. Resolve team UUID via `get_team` with `query: "Software Engineering"`
3. Fetch current cycle via `list_cycles` with `type: "current"` — note start/end dates
4. Fetch current cycle issues via `list_issues` with `cycle: "<cycle-id>"` — sum estimates by status
5. Fetch previous cycle via `list_cycles` with `type: "previous"` for velocity baseline
6. Check existing projects via `list_projects` with `team: "Software Engineering"`

Instruct the subagent to return:
```
## Duplicates
[matches with IDs and titles, or "None found"]

## Team
UUID: [uuid]

## Current Cycle
ID: [id], Start: [date], End: [date]
Load: [X] points planned, [Y] completed, [Z] remaining

## Velocity
Previous cycle: [X] points completed

## Active Projects
[names and target dates]
```

## Phase 3: Size

Using the codebase analysis results, determine the scope:

| Scope | Criteria | Action |
|-------|----------|--------|
| **Single issue** (1–3) | Few files, isolated change, one package | Create one issue |
| **Parent + sub-issues** (5) | Multiple files/packages, ordered delivery, one cycle | Read `references/decompose.md`, create parent + sub-tasks |
| **Full project** (8+) | Multi-cycle effort, multiple work streams | Read `references/project.md`, create project + milestones + parents |

The codebase analysis drives this decision — trust the Explore subagent's scope assessment and revise only if you have strong reason to.

## Phase 4: Plan Proposal

Present a complete plan for approval. **Never create issues without sign-off** (except the fix triage issue in Phase 1, which is intentionally created early).

### Load the Type Template

Read the template for the classified type from `references/templates/<type>.md`:

| Type | Template |
|------|----------|
| `feat` | `references/templates/feat.md` |
| `fix` | `references/templates/fix.md` |
| `chore` | `references/templates/chore.md` |
| `refactor` | `references/templates/refactor.md` |
| `spike` | `references/templates/spike.md` |

Each template defines the sections that matter for that type of work. Use it to structure the issue body — fill every section using data from the codebase analysis and Linear context subagents. Mark sections as "N/A" only if genuinely not applicable.

### Proposal Structure

```
**Type:** <category> — <one-line rationale>
**Severity:** <Critical/High/Normal/Low>        ← fix only
**Estimate:** <1/2/3/5/8+> — <rationale from codebase analysis>
**Scope:** <Single issue / Parent + sub-issues / Full project>
**Duplicates:** <matches found with IDs, or "None">
**Due Date:** <ISO date> — <reasoning from cycle capacity and velocity>

## Issue Draft

**Title:** type(scope): description

**Body:**
<filled template from references/templates/<type>.md — every section populated>
```

**For parent + sub-issues**, also present the sub-task dependency graph per `references/decompose.md`.

**For full project**, present the milestone breakdown and phase structure per `references/project.md`.

**For fix**, include investigation findings and recommend a triage action:

| Action | What happens |
|--------|-------------|
| **Accept** | Update triage issue: `state: "Backlog"`, drop "— investigating" suffix, add full spec |
| **Decline** | Update triage issue: `state: "Canceled"`, add reason |
| **Duplicate** | Update triage issue: `duplicateOf: "<original-id>"`, `state: "Canceled"` |
| **Snooze** | Inform engineer to snooze manually in Linear (no MCP support) |

### Due Date Reasoning

Derive the due date from the Linear context subagent's data:
- Given the estimate, current cycle load, and velocity baseline — when would this realistically complete?
- Align to cycle end dates where practical
- For fix with severity: Critical/High should target the current cycle; Normal/Low align to future cycles
- If the work has a project, check milestone target dates

## Phase 5: Execute

On approval, create in Linear.

### Single Issue

Create via `create_issue`:
- `title`, `team: "Software Engineering"`, `description` (spec + context + acceptance criteria + validation)
- `labels: ["<type>"]` (substring match, e.g. `"feat"`)
- `estimate: <fibonacci value>`, `dueDate: "<ISO date>"`
- `assignee` (ask or use `"me"`)
- `state: "Backlog"`
- `project: "<name>"` if applicable
- `blocks` / `blockedBy` if dependencies exist

**For fix:** update the existing triage issue instead of creating a new one:
- `id: "<triage-issue-id>"`
- `title: "fix(scope): description"` (drop "— investigating")
- `state: "Backlog"`, add full spec to description, set estimate and due date

### Parent + Sub-Issues

Read `references/decompose.md` and follow its process:
1. Create parent issue with `estimate: 5`
2. Create sub-issues with `parentId`, `blockedBy` chain, cascaded due dates
3. Each sub-task estimate 1–3, max 8 sub-tasks

### Full Project

Read `references/project.md` and follow its process:
1. Create project with milestones aligned to cycle boundaries
2. Create L-sized parent issues per milestone
3. Decompose first milestone's parents into sub-tasks (defer later milestones)

Return all created issue identifiers and URLs.

## Urgency Routing

All new work defaults to **Backlog**. If the engineer explicitly says "add to current cycle" or marks as urgent:

1. Use cycle info from the Linear context subagent.
2. Show current cycle load.
3. **Swap rule:** every mid-cycle addition requires deferring an issue of equal or greater estimate. Present current cycle contents and ask what to defer.
4. On approval: create with `state: "Todo"` and `cycle: "<cycle-id>"`. Defer the swapped issue with `cycle: null`, `state: "Backlog"`.

**Exception:** Critical bugs (priority 1) skip the swap rule — add without displacement.

## Constraints

- Keep acceptance criteria verifiable — no "works correctly."
- Keep titles clean: no IDs, no markdown. Concise and scannable.
- Each sub-task must be independently shippable (one PR).
- Max 8 sub-tasks per parent. Split the parent if more needed.
- For full projects: don't over-plan later milestones until the cycle before they start.
- The fix triage issue from Phase 1 is the single issue for that bug. All actions update it — never create additional issues.
- Don't over-investigate bugs. Document findings and move on if root cause isn't clear within the Explore subagent's analysis.
