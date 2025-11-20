In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Plans
At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

## Subagents
You have access to the athena subagent - consults knowledge base of tool repos. Use for questions about tools in `~/.config/opencode/knowledge.json`. Athena will decline if question not relevant to registered tools.

You also have access to the spartan subagent, an Arch Linux expert with complete Arch Wiki knowledge and deep suckless philosophy expertise (dwm, dmenu, dwmblocks, st). Consult for minimal system configs, patching suckless tools, and Arch-specific solutions.

## Knowledge Base Commands
- `oc kb-list` - show registered tools
- `oc kb-add <git-url> <name> <dir>` - add tool repo to knowledge base
- `oc kb-sync` - update all tool repos to latest
- `oc kb-remove <key>` - remove tool from registry + filesystem

Knowledge base stored at `$XDG_DATA_HOME/opencode/knowledge/`. Registry at `~/.config/opencode/knowledge.json`. Version control knowledge.json for backup/restore across machines.
