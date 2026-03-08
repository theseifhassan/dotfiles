# Refactor Issue Template

Use this template when the work is classified as `refactor`. The defining constraint of a refactor is that external behavior must not change — only the internal structure improves.

```markdown
## Problem
What's wrong with the current code. Why it needs restructuring.
Concrete pain points: hard to test, duplicated logic, unclear boundaries, poor naming.

## Current Architecture
How the code is structured today. Key files, patterns in use, data flow.
What specifically makes it hard to work with.

## Target Architecture
How the code should be structured after. New patterns, better boundaries.
Why this structure is better — not just different.

## Behavior Preservation
This refactor must not change external behavior. Specifically verify:
- [ ] [Behavior 1 still works exactly as before]
- [ ] [Behavior 2 still works exactly as before]
- [ ] [API contract unchanged: same inputs produce same outputs]

## Strategy
Step-by-step approach to the restructuring.
How to keep the codebase working at each step (no big-bang rewrites).

## Affected Areas
Files, packages, APIs, and consumers touched.

## Consumer Impact
[If the refactor touches shared code]
Which packages or modules consume the refactored code.
Any internal API changes that require consumer updates.

## Acceptance Criteria
- [ ] Behavior unchanged: [specific verification]
- [ ] Structure improved: [specific improvement, measurable if possible]
- [ ] No breaking changes to consumers

## Validation
pnpm typecheck && pnpm check
[Additional test commands — existing tests should still pass unchanged]
```
