---
description: Plan cycles, review progress, plan cooldown
model: opencode/gemini-3-flash
---

# Cycle Management

Route on `$ARGUMENTS`. Ask if missing.

**Team setup:** Resolve team UUID first via `get_team` with `query: "Software Engineering"` — needed for `list_cycles` which requires UUID, not name.

**Timing:** `plan` at cycle start (Monday morning). `review` mid-cycle. `cooldown` at cycle end, before a cooldown week.

## plan

Run at **cycle start** (Monday morning of week 1).

**1. Retro.** Get previous cycle via `list_cycles` with `teamId: "<uuid>"`, `type: "previous"`. List its issues via `list_issues` with `cycle: "<cycle-id>"`. Report:
- Planned vs done, carryover and why, patterns
- Summarize cooldown output
- **Mid-cycle swaps:** identify issues where `createdAt` is after the previous cycle's start date — these were urgency additions. Note what was deferred in exchange.

**2. Backlog.** Fetch via `list_issues` with `state: "Backlog"`, `team: "Software Engineering"`. For issues with potential blockers, check relations via `get_issue` with `includeRelations: true`. Flag: unresolved blockers, stale (>4 weeks by `updatedAt`), underspecced. Check projects via `list_projects` with `team: "Software Engineering"`.

**3. Capacity.** 2-week cycle, 2 engineers. Use previous cycle's completed estimates as velocity baseline. Account for rolled-over issues and known reductions (PTO, on-call — ask). Scale: 1/2/3/5.

**4. Propose.** Assign per engineer, estimate totals, ~15% buffer. Prioritize unblocking work. Flag risks, dependencies, milestones.

**5. Execute.** On approval, for each issue: `update_issue` with `state: "Todo"` and `cycle: "<active-cycle>"`. Get active cycle via `list_cycles` with `type: "current"` (or `type: "next"` if current hasn't started).

## review

Run **mid-cycle** (end of week 1, or on demand).

Get current cycle via `list_cycles` with `type: "current"`. List issues via `list_issues` with `cycle: "<cycle-id>"`.

Report:
- Done / In Progress / Not Started with estimates
- Completed vs planned (sum estimates by status)
- **Scope changes:** issues where `createdAt` is after cycle start date — these are mid-cycle additions
- **Swaps:** for each mid-cycle addition, note what was deferred and the net point delta
- Project milestones via `get_project` with `includeMilestones: true`

**Swap rule enforcement:** If mid-cycle additions exist without corresponding deferrals, flag the imbalance. Every addition requires a subtraction of equal or greater estimate. Critical bugs (priority 1) are the only exception.

If off track: suggest deferrals. If ahead: suggest pulling from backlog.

## cooldown

Run at **cycle end**, before a cooldown week. Suggest focus areas — no commitments.

Analyze:
- Triage queue via `list_issues` with `state: "Triage"`, `team: "Software Engineering"`
- Backlog quick wins via `list_issues` with `state: "Backlog"`, `team: "Software Engineering"` (filter for estimate 1-2 in results)
- Project health via `list_projects` with `team: "Software Engineering"`, then `list_milestones` for approaching deadlines

Suggest 3-5 focus areas ranked by impact. This is for suggesting focus, not planning commitments — cooldown is intentionally loose. Triage queue processing happens here.
