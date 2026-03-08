---
name: cycle
description: Plan development cycles, review mid-cycle progress, and plan cooldown weeks. Subcommands — plan, review, cooldown. Use at cycle boundaries (start/mid/end) or when planning cooldown work. Triggers on "plan the cycle", "cycle review", "how's the cycle going", "cooldown", "what should we work on next", "sprint planning", or any cycle/sprint management context.
argument-hint: [plan|review|cooldown]
allowed-tools: mcp__linear, Agent
---

# Cycle Management

Route on `$ARGUMENTS`. Ask if missing.

**Team setup:** Resolve team UUID first via `get_team` with `query: "Software Engineering"` — needed for `list_cycles` which requires UUID, not name.

**Timing:** `plan` at cycle start (Monday morning). `review` mid-cycle. `cooldown` at cycle end, before a cooldown week.

## plan

Run at **cycle start** (Monday morning of week 1).

### Data Gathering (Parallel Subagents)

Launch two subagents simultaneously to gather all the data needed for planning. This keeps the main context focused on analysis and decision-making.

**Subagent 1: Retro Data** (general-purpose)

Instruct it to:
1. Resolve team UUID via `get_team` with `query: "Software Engineering"`
2. Get previous cycle via `list_cycles` with `teamId: "<uuid>"`, `type: "previous"`
3. List previous cycle issues via `list_issues` with `cycle: "<cycle-id>"`
4. For each issue, note: title, estimate, status, labels, assignee
5. Identify mid-cycle swaps: issues where `createdAt` is after the cycle's start date
6. Return a structured summary:
   ```
   ## Previous Cycle
   ID: [id], Start: [date], End: [date]

   ## Completed
   [list with titles, estimates]
   Total: [X] points

   ## Incomplete / Carried Over
   [list with titles, estimates, status, reason if apparent]

   ## Mid-Cycle Additions
   [issues added after cycle start, with what was deferred]

   ## Velocity
   Completed: [X] points out of [Y] planned
   ```

**Subagent 2: Backlog & Projects** (general-purpose)

Instruct it to:
1. Fetch backlog via `list_issues` with `state: "Backlog"`, `team: "Software Engineering"`
2. For issues with potential blockers, check relations via `get_issue` with `includeRelations: true`
3. Check projects via `list_projects` with `team: "Software Engineering"`
4. For active projects, fetch milestones via `get_project` with `includeMilestones: true`
5. Get current (or next) cycle via `list_cycles` with `type: "current"` (or `type: "next"`)
6. Return a structured summary:
   ```
   ## Backlog
   [list with titles, estimates, labels, age, blockers]
   Flagged: stale (>4 weeks), underspecced, blocked

   ## Active Projects
   [project names, milestone dates, progress]

   ## Upcoming Cycle
   ID: [id], Start: [date], End: [date]
   ```

### Analysis & Proposal (Main Context)

With both subagent summaries in hand:

**1. Retro.** Summarize the previous cycle from Subagent 1's data:
- Planned vs done, carryover and why, patterns
- Mid-cycle swaps and their impact
- Velocity trend

**2. Backlog Review.** From Subagent 2's data, flag:
- Unresolved blockers
- Stale issues (>4 weeks since `updatedAt`)
- Underspecced issues — suggest re-speccing via `/capture`
- Project milestones approaching

**3. Capacity.** 2-week cycle, 2 engineers. Use previous cycle's completed estimates as velocity baseline. Account for rolled-over issues and known reductions (PTO, on-call — ask). Scale: 1/2/3/5.

**4. Propose.** Assign per engineer, estimate totals, ~15% buffer. Prioritize unblocking work. Flag risks, dependencies, milestones.

**5. Execute.** On approval, for each issue: `update_issue` with `state: "Todo"` and `cycle: "<active-cycle>"`.

## review

Run **mid-cycle** (end of week 1, or on demand).

### Data Gathering (Subagent)

Launch a **general-purpose** subagent to gather cycle data:
1. Get current cycle via `list_cycles` with `type: "current"`
2. List cycle issues via `list_issues` with `cycle: "<cycle-id>"`
3. For issues with projects, fetch via `get_project` with `includeMilestones: true`
4. Return:
   ```
   ## Cycle
   ID: [id], Start: [date], End: [date]

   ## Issues by Status
   Done: [list with estimates] — Total: [X]
   In Progress: [list with estimates] — Total: [X]
   Not Started: [list with estimates] — Total: [X]

   ## Mid-Cycle Additions
   [issues where createdAt > cycle start, with what was deferred]

   ## Project Milestones
   [approaching milestones with dates and progress]
   ```

### Analysis (Main Context)

Report:
- Done / In Progress / Not Started with estimates
- Completed vs planned (sum estimates by status)
- **Scope changes:** mid-cycle additions and their impact
- **Swaps:** for each addition, what was deferred and the net point delta

**Swap rule enforcement:** If mid-cycle additions exist without corresponding deferrals, flag the imbalance. Every addition requires a subtraction of equal or greater estimate. Critical bugs (priority 1) are the only exception.

If off track: suggest deferrals. If ahead: suggest pulling from backlog.

## cooldown

Run at **cycle end**, before a cooldown week. Suggest focus areas — no commitments.

### Data Gathering (Subagent)

Launch a **general-purpose** subagent to gather:
1. Triage queue via `list_issues` with `state: "Triage"`, `team: "Software Engineering"`
2. Backlog quick wins via `list_issues` with `state: "Backlog"`, `team: "Software Engineering"` (filter for estimate 1-2)
3. Project health via `list_projects` with `team: "Software Engineering"`, then `list_milestones` for approaching deadlines
4. Return:
   ```
   ## Triage Queue
   [issues pending triage with titles, priorities, age]

   ## Quick Wins (estimate 1-2)
   [backlog issues that could be knocked out during cooldown]

   ## Project Health
   [milestones approaching, projects at risk]
   ```

### Analysis (Main Context)

Suggest 3-5 focus areas ranked by impact. This is for suggesting focus, not planning commitments — cooldown is intentionally loose. Triage queue processing happens here.
