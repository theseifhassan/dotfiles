# Decompose into Sub-Tasks

## Process

1. Fetch parent issue via `get_issue` with `id: "<issue-id>"` and `includeRelations: true`. Note its `project` and `id` (UUID needed for `parentId`).
2. Explore codebase to understand scope and boundaries.
3. Propose sub-tasks. Each must have:
   - Title per naming conventions
   - Type and estimate (1-3 only — decompose further if 5+)
   - Spec and verifiable acceptance criteria
   - Dependencies on other sub-tasks
   - Due date — derived from the parent's due date, working backward through the dependency chain. Space sub-task due dates based on their estimates and the team's velocity. The last sub-task's due date should match the parent's due date.
4. Present as a dependency graph:
   ```
   1. refactor(auth): extract shared types        [no deps]
   2. feat(auth): add auth schema                  [← 1]
   3. feat(auth): add API routes                   [← 2]
   4. feat(auth): add middleware                    [← 3]
   ```
5. Wait for approval. Iterate on scope, order, estimates as needed.
6. Create sub-issues in order via `create_issue` for each:
   - `title`, `team: "Software Engineering"`, `description`
   - `parentId: "<parent-uuid>"` (links as sub-issue)
   - `labels: ["<type>"]`, `estimate`, `state: "Backlog"`
   - `dueDate: "<ISO date>"` (cascaded from parent, spaced by dependency order)
   - `project: "<name>"` if parent has a project
   - `blockedBy: ["<previous-sub-issue-identifier>"]` to enforce dependency order
7. Return list of created issues with identifiers, titles, and dependency chain.

**Relations gotcha:** `blocks`/`blockedBy` on `create_issue` accept identifiers (e.g. `"SWE-5"`). Set them at creation time — no need to read-then-merge like with `update_issue`.

## Constraints

- Each sub-task must be independently shippable (one PR, passes validation alone).
- Prefer vertical slices over horizontal layers.
- Max 8 sub-tasks. If more needed, split the parent into separate efforts.
- Parent stays open until all sub-tasks are Done.
