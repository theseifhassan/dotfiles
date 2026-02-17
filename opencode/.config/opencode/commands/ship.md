---
description: Validate code, create Graphite branch, submit PR
model: opencode/gemini-3-flash
---

# Ship

Current branch: !`git branch --show-current`
Staged: !`git diff --cached --stat`
Unstaged: !`git diff --stat`
Untracked: !`git ls-files --others --exclude-standard`
Stack: !`gt log short 2>/dev/null || echo 'no stack'`

## Process

1. Run `pnpm typecheck && pnpm check`. Run `pnpm test` if tests exist. **Stop on failure.**
2. Determine issue context (ID, type, scope, description) from session or ask.
3. Derive commit message and branch name per naming conventions.
4. Branch and commit:
   - On trunk: `gt create --all --message "type(scope): desc [SWE-XXX]" type/short-desc`
   - On existing Graphite branch: `gt modify --all`
5. Run `gt submit`.
6. Enrich the PR via `gh pr edit`:
   - Fetch the Linear issue via `get_issue` if not already loaded.
   - Compose the PR body:
     ```
     ## Summary
     <1-3 bullet points derived from the Linear issue description>

     ## Linear Issue
     SWE-XXX

     ## Test Plan
     <From acceptance criteria if available, otherwise: `pnpm typecheck && pnpm check`>
     ```
   - Run: `gh pr edit --add-assignee "@me" --add-label "<type>" --body "<body>"`
   - If the label doesn't exist, create it: `gh label create "<type>"`.
7. Return PR link. Remind: XS/S self-review, M+ peer review.

## Constraints

- Do NOT move issue to Done. GitHub integration handles this on merge.
- No Linear IDs in branch names.
- No changes = nothing to ship. Stop.
- `gt submit` submits current + downstack. Use `--stack` only if engineer wants upstack too.
- If `gh pr edit` fails (auth, network), warn but don't block. The PR exists; enrichment is best-effort.
