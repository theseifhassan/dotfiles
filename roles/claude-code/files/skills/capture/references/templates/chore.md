# Chore Issue Template

Use this template when the work is classified as `chore`. Chores are maintenance work — they don't change product behavior but improve the development experience, infrastructure, or operational health.

```markdown
## Motivation
Why this maintenance is needed now. What pain or risk it addresses.
What happens if we don't do this.

## Current State
How things work today. What's wrong or outdated.

## Desired State
How things should work after this change. The target outcome.

## Changes
What specifically needs to change:
- Dependencies: [upgrades, additions, removals]
- Config: [files and settings affected]
- CI/CD: [pipeline changes]
- Tooling: [developer experience changes]
- Infrastructure: [deployment or environment changes]

## Migration Plan
[If applicable — mark N/A if no migration needed]
Steps to migrate. Breaking changes for consumers and how to handle them.
Order of operations if changes must be sequenced.

## Rollback Plan
How to revert if something goes wrong. Steps to restore previous state.

## Affected Areas
Files, packages, config, CI pipelines touched.

## Acceptance Criteria
- [ ] Criterion — verifiable outcome, not "it works"
- [ ] Criterion — include build/CI verification
- [ ] No breaking changes to: [consumers or workflows]

## Validation
pnpm typecheck && pnpm check
[Additional verification: CI passes, build succeeds, etc.]
```
