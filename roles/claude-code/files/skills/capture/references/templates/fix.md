# Fix Issue Template

Use this template when the work is classified as `fix`. The goal is to document both the problem and the solution clearly enough that someone can verify the fix and understand the risk.

```markdown
## Bug Report
What's broken. Expected behavior vs actual behavior.

## Reproduction Steps
1. [Precondition or setup]
2. [Action that triggers the bug]
3. Observe: [what actually happens]
4. Expected: [what should happen instead]

## Severity
[Critical/High/Normal/Low] — [impact: who is affected, how badly, any workaround]

## Root Cause
[From codebase investigation]
What's causing the bug — file paths, line numbers, the specific flaw.
If root cause is uncertain, state what's known and what's hypothesized.

## Fix
What needs to change to resolve the issue. Be specific about the approach.

## Affected Areas
Files, packages, routes touched by the fix.

## Regression Risk
What could break when fixing this. Adjacent behavior to verify.
Areas where the fix might have unintended side effects.

## Acceptance Criteria
- [ ] Bug is fixed: [specific verification matching the repro steps]
- [ ] No regression in: [related area]
- [ ] Edge case handled: [relevant edge case]

## Validation
pnpm typecheck && pnpm check
[Additional test commands if relevant]
```
