---
name: start
description: Begin work on a Linear issue end-to-end. Validates trunk state, fetches the spec, plans the implementation via codebase analysis, implements the approved plan, then runs parallel code reviews (bugs, performance, security, logic) in a fix loop until clean. Use at the start of any implementation task. Triggers on "start working on", "pick up SWE-", "begin SWE-", "work on SWE-", or any issue ID reference at work start.
argument-hint: [issue-id]
allowed-tools: mcp__linear, Bash, Agent, Read, Grep, Glob, Edit, Write
---

# Start Work

Current branch: !`git branch --show-current`
Uncommitted changes: !`git status --short`

## Phase 1: Pre-flight

1. **Verify trunk.** The current branch must be trunk (`master` or `main`). If on any other branch, warn the user and **stop**. Do not proceed on a feature branch.
2. **Check for dirty state.** If `git status --short` shows any output (untracked, unstaged, or staged changes), warn the user and **stop**. The working tree must be clean before starting new work.
3. Run `gt sync` to ensure trunk is up to date.

## Phase 2: Load Context

1. Fetch issue via `get_issue` with `id: "$ARGUMENTS"` and `includeRelations: true`.
2. Display: title, spec, acceptance criteria, estimate, labels, project, and relations.
3. Check `relations.blockedBy` — if any blocking issues are not Done, warn the engineer and **stop**.
4. If the issue lacks a clear spec or acceptance criteria, flag it as underspecced and suggest re-speccing via `/capture`. Do not proceed with vague issues.
5. Move to In Progress via `update_issue` with `id: "<issue-id>"` and `state: "In Progress"`.

## Phase 3: Execution Plan

Launch an **Explore** subagent to analyze the codebase in context of the issue. Include the full issue body (spec, acceptance criteria, estimate) in the prompt. Instruct it to:

- Identify all files, modules, and packages that need to change
- Read existing code to understand current patterns and conventions
- Map dependencies between the changes
- Identify potential risks, edge cases, and gotchas
- Note any existing tests that cover the affected areas
- Return a structured report with: files to modify, files to create, dependencies and ordering, risks

Using the subagent's analysis and the issue body, compose an execution plan:

```
## Execution Plan

**Issue:** SWE-XXX — type(scope): description
**Estimate:** X

### Steps
1. [what to change, which file, why — grounded in codebase findings]
2. [next change, which file, why]
...

### Files to Modify
- path/to/file.ts — [what changes and why]

### Files to Create
- path/to/new.ts — [purpose]

### Dependencies & Order
[which steps depend on others, suggested sequence]

### Risks & Edge Cases
[potential issues to watch for, from the Explore subagent's findings]

### Validation
pnpm typecheck && pnpm check
[additional test commands if relevant]
```

Present the plan and **wait for approval**. Do not begin implementation until the user signs off. Iterate on the plan if the user has feedback.

## Phase 4: Implement

Execute the approved plan step by step. Follow the codebase's existing patterns and conventions — read neighboring code before writing to match style.

After completing all steps, run validation:

```bash
pnpm typecheck && pnpm check
```

If tests exist for the affected area, run them too. Fix any validation failures before proceeding to review.

## Phase 5: Code Review Loop

After implementation is complete and validation passes, run a thorough code review. Launch **four review subagents in parallel** — each independently reads every changed file and reviews from a different angle. These reviewers must be exhaustive: no issue is too small to report.

Get the list of changed files via `git diff --name-only` and include it in each subagent's prompt, along with the issue spec for context.

### Subagent 1: Bug Reviewer (general-purpose)

> You are a meticulous bug hunter reviewing a code change. Read every changed file listed below in full. Assume nothing works correctly until you've verified it.
>
> Check for:
> - Off-by-one errors, null/undefined access, missing error handling
> - Incorrect conditional logic, wrong operators, inverted conditions
> - Race conditions, stale closures, missing cleanup
> - Incorrect function signatures, wrong argument order, type mismatches
> - Missing await on async calls, unhandled promise rejections
> - Edge cases: empty arrays, zero values, empty strings, undefined properties
> - State management issues: stale state, missing updates, incorrect hook dependencies
>
> For each issue found, report:
> ```
> **BUG [critical/major/minor]** path/to/file.ts:42
> Issue: [what's wrong]
> Fix: [how to fix it]
> ```
> If no issues found, state "No bugs found" and briefly explain what you verified.

### Subagent 2: Performance Reviewer (general-purpose)

> You are a performance specialist reviewing a code change. Read every changed file listed below in full. Think about scale and hot paths.
>
> Check for:
> - Unnecessary re-renders in React (missing memoization, unstable references in deps)
> - N+1 query patterns, unbounded data fetching, missing pagination
> - Expensive operations inside loops or hot paths
> - Missing indexes for database queries
> - Large bundle impact: unnecessary imports, missing code splitting, heavy dependencies
> - Memory leaks: event listeners not cleaned up, subscriptions not unsubscribed
> - Inefficient data structures or algorithms for the data scale involved
>
> For each issue found, report:
> ```
> **PERF [high/medium/low]** path/to/file.ts:42
> Issue: [what's wrong]
> Fix: [how to fix it]
> ```
> If no issues found, state "No performance issues found" and briefly explain what you verified.

### Subagent 3: Security Reviewer (general-purpose)

> You are a security auditor reviewing a code change. Read every changed file listed below in full. Think like an attacker.
>
> Check for:
> - Injection: SQL injection, command injection, XSS, template injection
> - Auth gaps: missing auth checks, privilege escalation paths
> - Data exposure: sensitive data in logs, error messages, or API responses
> - Input validation: missing or insufficient validation at system boundaries
> - CSRF, SSRF, open redirect vulnerabilities
> - Insecure defaults: permissive CORS, missing security headers, weak crypto
> - Secrets: hardcoded credentials, API keys, tokens in code
> - Unsafe deserialization, prototype pollution, path traversal
>
> For each issue found, report:
> ```
> **SEC [critical/high/medium/low]** path/to/file.ts:42
> Issue: [what's wrong]
> Fix: [how to fix it]
> ```
> If no issues found, state "No security issues found" and briefly explain what you verified.

### Subagent 4: Logic Reviewer (general-purpose)

> You are a domain logic expert reviewing a code change. Read the issue spec carefully, then read every changed file listed below in full. Verify the implementation actually achieves what was specified.
>
> Check for:
> - Implementation doesn't match the spec or acceptance criteria
> - Missing edge case handling that the spec implies
> - Incorrect business logic, wrong calculations, flawed state machines
> - Inconsistent behavior across code paths
> - Missing validation that the domain requires
> - Data flow issues: data transformed incorrectly, lost in transit, or not propagated
> - API contract violations: response shape doesn't match consumer expectations
> - Incorrect assumptions about data shape, optionality, or invariants
>
> For each issue found, report:
> ```
> **LOGIC [critical/major/minor]** path/to/file.ts:42
> Issue: [what's wrong]
> Fix: [how to fix it]
> ```
> If no issues found, state "No logic issues found" and briefly explain what you verified.

### Process Results

Collect all four review reports. If **any** reviewer found issues:

1. Present all findings grouped by reviewer.
2. Fix every reported issue — critical and major first, then minor.
3. Run validation again: `pnpm typecheck && pnpm check`
4. Re-launch all four reviewers in parallel on the updated code.
5. Repeat until all four reviewers report clean.

When all reviewers pass clean, inform the user the implementation is complete and ready for `/ship`.

## Constraints

- Do NOT create a branch. Code on trunk. Branch via `/ship`.
- Do NOT proceed past pre-flight if the working tree is dirty or not on trunk.
- Do NOT implement without plan approval.
- Do NOT skip the review loop. Every implementation gets reviewed before it's ready to ship.
