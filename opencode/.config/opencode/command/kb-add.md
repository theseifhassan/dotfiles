---
description: Add a new repo to the knowledge base
subtask: true
---

Add a new tool repository to the knowledge base.

Git URL: $1
Tool name: $2
Directory name: $3

Steps:
1. Read `~/.config/opencode/knowledge.json`
2. Construct knowledgeDir using bash: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
3. Generate unique key from $2 (lowercase, no spaces/special chars)
4. Verify $1 is valid git URL
5. Construct target path: `REPO_PATH="$KNOWLEDGE_DIR/$3"`
6. Check if `$REPO_PATH/.git` exists using `[ -d "$REPO_PATH/.git" ]` → error if exists
7. Check if key already in knowledge.json → error if exists
8. Add to knowledge.json:
   ```json
   "<key>": {
     "name": "$2",
     "repo": "$1",
     "dir": "$3"
   }
   ```
9. Write updated knowledge.json
10. Create dir: `mkdir -p "$KNOWLEDGE_DIR"`
11. Clone: `git clone --depth 1 $1 "$REPO_PATH"`
12. Show: "Added $2 (<key>) → $REPO_PATH"

Error handling:
- If key exists → error "Tool '<key>' already in knowledge base"
- If clone fails → remove from knowledge.json, show git error

CRITICAL:
- NEVER use `cd` command - it's forbidden outside working directory
- Construct absolute paths using bash vars: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
- All commands must use full absolute paths with variable expansion

Example:
```bash
KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"
REPO_PATH="$KNOWLEDGE_DIR/effect"
git clone --depth 1 https://github.com/Effect-TS/effect "$REPO_PATH"
```
