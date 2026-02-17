---
description: Capture a bug report, create a triage issue, and investigate root causes
model: opencode/claude-sonnet-4-5
---

# Bug Triage & Investigation

Parse `$ARGUMENTS` as the bug report. Clarify: affected feature, severity, repro steps, when it started.

## Process

1. Search for duplicates via `list_issues` with `query: "<keywords>"`, `team: "Software Engineering"`, `state: "triage"`. If found, show existing issue and recommend linking.
2. Create triage issue immediately via `create_issue`:
   - `title: "bug(scope): description — investigating"`
   - `team: "Software Engineering"`
   - `state: "Triage"`, `labels: ["fix"]`
   - `priority`: `1` (urgent), `2` (high), `3` (normal), `4` (low) — based on severity
   - `estimate` if estimable
   - `description`: raw report + clarifying info
   - If duplicate found: `duplicateOf: "<original-issue-id>"`
3. Investigate codebase. Find relevant code paths, identify failure points, check recent changes.
4. Present findings with file paths and line numbers.
5. **Plan due date.** Before recommending a triage action, derive a due date for accepted bugs:
   - Resolve team UUID via `get_team` with `query: "Software Engineering"`.
   - Fetch current cycle via `list_cycles` with `type: "current"` — note end date and remaining capacity.
   - Fetch current cycle issues via `list_issues` with `cycle: "<cycle-id>"` — gauge remaining load.
   - Check `list_cycles` with `type: "previous"` for velocity baseline.
   - Derive due date based on priority, estimate, current load, and cycle boundaries. P1-P2 bugs entering the current cycle should be due within the cycle. P3-P4 bugs should be due by the end of the cycle they'd realistically be pulled into.
6. Recommend triage action and execute on approval. Apply the chosen action to the triage issue from step 2, referencing it by ID:

   | Action | MCP Call |
   |--------|---------|
   | Accept | `update_issue` with `state: "Backlog"`, `dueDate: "<ISO date>"`, `title: "bug(scope): description"` (drop the "— investigating" suffix). Update `description` with full spec. |
   | Decline | `update_issue` with `state: "Canceled"`. Add reason to description. |
   | Duplicate | `update_issue` with `duplicateOf: "<original>"`, `state: "Canceled"`. |
   | Snooze | Inform engineer to snooze manually in Linear (no MCP support). |

7. Route by severity:
   - **Critical** (production down): skip ceremony, fix now.
   - **High** (broken, workaround exists): fix today.
   - **Normal** (not blocking): standard priority.
   - **Low** (cosmetic/rare): backlog for cooldown.

## Urgency Routing

After triage, route based on priority:

**Urgent/High (priority 1-2):** Suggest adding to the current cycle.

1. Fetch cycle via `list_cycles` with `type: "current"`.
2. Show current cycle load via `list_issues` with `cycle: "<cycle-id>"`.
3. Apply the **swap rule** — every mid-cycle addition requires deferring an issue of equal or greater estimate. Present options and ask what to defer. Critical bugs (priority 1) skip the swap — add without displacement.
4. On approval: `update_issue` with `state: "Todo"`, `cycle: "<cycle-id>"`. Defer the swapped issue with `cycle: null`, `state: "Backlog"`.

**Normal/Low (priority 3-4):** Stays in **Backlog**. Next `/cycle plan` picks it up.

## Constraints

- Always create the triage issue before investigating.
- If root cause found, offer to upgrade to full spec with acceptance criteria.
- Don't over-investigate. Document findings and move on if root cause isn't clear.
- The triage issue from step 2 is the single issue for this bug. All triage actions in step 6 update it via `update_issue` using its ID. Never create additional issues.
