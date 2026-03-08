# Project-Scope Work

## Process

1. **Analyze timeline.** Before creating anything, plan the project timeline:
   - Resolve team UUID via `get_team` with `query: "Software Engineering"`.
   - Fetch velocity baseline via `list_cycles` with `type: "previous"` — completed estimates per cycle.
   - Fetch current cycle via `list_cycles` with `type: "current"` — note cycle cadence and end dates.
   - Check existing projects via `list_projects` with `team: "Software Engineering"` for roadmap context.
   - Estimate total scope (sum of all parent issues), divide by velocity to project how many cycles this spans, and derive a realistic project target date. Align milestones to cycle boundaries.

2. **Create the Linear project** via `create_project`:
   - `name`: clear, goal-oriented name
   - `team: "Software Engineering"`
   - `description`: high-level objective and success criteria
   - `priority`: based on urgency (0=None, 1=Urgent, 2=High, 3=Medium, 4=Low)
   - `startDate` and `targetDate` (from timeline analysis)

3. **Define milestones** for checkpoints within the project via `create_milestone`:
   - Each milestone represents a meaningful deliverable
   - Set `targetDate` aligned to cycle end dates based on the timeline analysis
   - Milestones help `/cycle plan` prioritize across projects

4. **Break into L-sized parent issues.** Each parent issue maps to a milestone or logical phase:
   - Create via `create_issue` with `project: "<project-name>"`
   - `estimate: 5` (L-sized, will be decomposed further)
   - `dueDate`: inherit from the milestone's `targetDate`
   - `state: "Backlog"` — `/cycle plan` assigns them to cycles
   - `milestone: "<milestone-name>"` if applicable
   - Set `blockedBy` between parent issues if there's a strict phase order

5. **Decompose each parent issue.** For each L-sized parent, follow the decomposition process in `references/decompose.md`:
   - Fetch the parent, explore codebase
   - Propose sub-tasks as a dependency graph
   - Create sub-issues with `parentId`, `blockedBy` chain, and `dueDate` (cascaded from parent)

6. Present the full structure for approval:
   ```
   Project: Auth System Overhaul
   ├── Milestone 1: Core Auth (Cycle N)
   │   └── feat(auth): add auth schema [L]
   │       ├── refactor(auth): extract shared types [S]
   │       ├── feat(auth): add schema [M]
   │       └── feat(auth): add migrations [S]
   ├── Milestone 2: API Layer (Cycle N+1)
   │   └── feat(auth): add API routes [L]
   │       ├── feat(auth): add auth endpoints [M]
   │       └── feat(auth): add middleware [M]
   └── Milestone 3: UI (Cycle N+2)
       └── feat(auth): add login UI [L]
           ├── feat(auth): add login form [M]
           └── feat(auth): add session management [M]
   ```

7. All issues land in **Backlog**. `/cycle plan` pulls them into cycles based on milestone priority and capacity.

## Constraints

- Every project needs a clear goal — not a bucket for miscellaneous work.
- Each L-sized parent must decompose into 2-8 sub-tasks via `references/decompose.md`.
- Sub-tasks must be independently shippable (one PR each).
- Milestones should align with cycle boundaries where practical.
- Don't over-plan — later milestones can stay coarser until the cycle before they start.
