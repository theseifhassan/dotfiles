---
description: Sync all knowledge base repos
subtask: true
---

Update all tool repositories in the knowledge base to latest versions.

Steps:
1. Read `~/.config/opencode/knowledge.json`
2. Construct knowledgeDir absolute path using bash:
   - Use: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
3. Create knowledge dir: `mkdir -p "$KNOWLEDGE_DIR"`
4. For each tool in `tools` object:
   - Construct absolute path: `REPO_PATH="$KNOWLEDGE_DIR/<tool.dir>"`
   - Check if `$REPO_PATH/.git` exists using `[ -d "$REPO_PATH/.git" ]`
     - **Exists**: Run `git -C "$REPO_PATH" pull origin HEAD`
     - **Not exists**: Run `git clone --depth 1 <tool.repo> "$REPO_PATH"`
   - Show status: `✓ <tool.name>: UPDATED` or `✓ <tool.name>: CLONED` or `✗ <tool.name>: FAILED`

Output format:
```
Syncing knowledge base repos...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Effect.ts: UPDATED
✓ Next.js: UPDATED
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sync complete! (7 updated, 2 cloned, 0 failed)
```

CRITICAL:
- NEVER use `cd` command - it's forbidden outside working directory
- Construct absolute paths using bash vars: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
- All commands must use full absolute paths with variable expansion
- Use `git -C "$ABSOLUTE_PATH"` for all git operations
- Continue on failures, report at end

Example:
```bash
KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"
mkdir -p "$KNOWLEDGE_DIR"
git -C "$KNOWLEDGE_DIR/effect" pull origin HEAD
```
