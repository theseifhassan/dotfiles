# Feature Issue Template

Use this template when the work is classified as `feat`. Fill every section — mark sections as "N/A" only if genuinely not applicable.

```markdown
## Context
Why this feature is needed. What user problem does it solve. Business motivation.

## User Stories
- As a [role], I want [capability] so that [benefit]

## Spec
Detailed behavior description — what the feature does, how it works, key interactions.

## UI/UX
[If applicable — mark N/A if backend-only]
Screens, interactions, component states (loading, empty, error, success).
Note any new components needed vs existing ones to reuse.

## API Design
[If applicable — mark N/A if frontend-only]
Endpoints, methods, request/response shapes, authentication requirements.
Note any new routes vs modifications to existing ones.

## Data Model
[If applicable — mark N/A if no schema changes]
New tables, columns, relations, migrations needed.
Note impact on existing queries and indexes.

## Affected Areas
Files, packages, routes, and patterns touched (from codebase analysis).

## Acceptance Criteria
- [ ] Criterion — must be verifiable, not subjective
- [ ] Criterion — one behavior per line
- [ ] Criterion — include edge cases worth verifying

## Out of Scope
What this feature intentionally does NOT include. Prevents scope creep.

## Validation
pnpm typecheck && pnpm check
[Additional test commands if relevant]
```
