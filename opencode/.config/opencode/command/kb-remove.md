---
description: Remove a tool from knowledge base
subtask: true
---

Remove tool "$1" from knowledge base registry and delete its repository.

Steps:
1. Read `~/.config/opencode/knowledge.json`
2. Check if "$1" exists in tools object
   - If NO → error "Tool '$1' not found. Run '/kb-list' to see available tools."
3. Get tool details (name, dir)
4. Construct knowledgeDir using bash: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
5. Construct absolute target path: `REPO_PATH="$KNOWLEDGE_DIR/<tool.dir>"`
6. Delete directory: `rm -rf "$REPO_PATH"` (if exists)
7. Remove "$1" entry from knowledge.json
8. Write updated knowledge.json
9. Show: "Removed <tool.name> ($1) from knowledge base and deleted $REPO_PATH"

Safety:
- Confirm before deleting if dir exists and is large (>100MB)
- Show warning if dir doesn't exist but registry entry does

CRITICAL:
- NEVER use `cd` command - it's forbidden outside working directory
- Construct absolute paths using bash vars: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
- All commands must use full absolute paths with variable expansion

Example:
```bash
KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"
REPO_PATH="$KNOWLEDGE_DIR/effect"
rm -rf "$REPO_PATH"
```
