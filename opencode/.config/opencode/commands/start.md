---
description: Begin work on a Linear issue
model: opencode/gemini-3-flash
---

# Start Work

Current branch: !`git branch --show-current`
Stack: !`gt log short 2>/dev/null || echo 'no stack'`
Uncommitted changes: !`git status --short`

## Process

1. Fetch issue via `get_issue` with `id: "$ARGUMENTS"` and `includeRelations: true`. Display title, spec, acceptance criteria, estimate, labels, project, and relations.
2. Check `relations.blockedBy` — if any blocking issues are not Done, warn the engineer.
3. Warn if uncommitted changes exist.
4. Move to In Progress via `update_issue` with `id: "<issue-id>"` and `state: "In Progress"`.
5. Run `gt sync`.
6. Apply sized behavior per workflow rules:
   - **1-2:** Ready. No ceremony.
   - **3:** Confirm approach. Surface spec gaps.
   - **5:** Recommend Plan Mode (`Tab`). Show sub-tasks and suggested start point.

## Constraints

- Do NOT create a branch. Code on trunk or stack tip. Branch via `/ship`.
- Do NOT implement. This skill only loads context.
- Flag underspecced issues before proceeding.
