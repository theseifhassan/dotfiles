---
description: List all tools in knowledge base
subtask: true
---

Display all registered tools in the knowledge base.

Steps:
1. Read `~/.config/opencode/knowledge.json`
2. Construct knowledgeDir using bash: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
3. For each tool in `tools` object, show:
   - Key (tool identifier)
   - Name (display name)
   - Directory (relative to knowledge base)
   - Status: construct `REPO_PATH="$KNOWLEDGE_DIR/<tool.dir>"` and check if `$REPO_PATH/.git` exists using `[ -d "$REPO_PATH/.git" ]`

Output format:
```
Knowledge Base Tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

effect       Effect.ts          effect/        ✓ cloned
nextjs       Next.js            next.js/       ✓ cloned
drizzle      Drizzle ORM        drizzle-orm/   ✗ not cloned
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
9 tools registered (8 cloned, 1 missing)

Run '/kb-sync' to clone missing repos.
```

Format as table with aligned columns. Show summary at end.

CRITICAL:
- NEVER use `cd` command - it's forbidden outside working directory
- Construct absolute paths using bash vars: `KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"`
- All filesystem checks must use full absolute paths with variable expansion

Example:
```bash
KNOWLEDGE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/knowledge"
[ -d "$KNOWLEDGE_DIR/effect/.git" ] && echo "cloned" || echo "not cloned"
```
