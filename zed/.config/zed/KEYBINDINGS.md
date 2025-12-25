# Zed Vim Power User Keybindings Quick Reference

## File Navigation & Fuzzy Finding

| Keybinding | Action | Description |
|------------|--------|-------------|
| `cmd-p` / `ctrl-p` | Television File Finder | Enhanced fuzzy file finder (overrides default) |
| `space space` | Built-in File Finder | Fallback Zed file finder |
| `space ,` | Buffer Switcher | Switch between open buffers |
| `space f r` | Recent Projects | Open recent projects |

## Search

| Keybinding | Action | Description |
|------------|--------|-------------|
| `space /` | Project Search | Search across entire project |
| `space s g` | Project Search (Grep) | Same as above |
| `space s b` | Buffer Search | Search in current buffer |
| `space s s` | Symbol Outline | Navigate symbols in current file |

## TUI Integration

| Keybinding | Action | Description |
|------------|--------|-------------|
| `cmd-shift-g` | Lazygit | Open lazygit in centered pane |
| `cmd-shift-d` | Lazydocker | Open lazydocker in centered pane |
| `ctrl-alt-o` | OpenCode | Open OpenCode agent |
| `ctrl-\`` | Terminal Toggle | Toggle terminal panel focus |

## Vim Window Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `ctrl-w h` | Navigate Left | Move to left pane |
| `ctrl-w j` | Navigate Down | Move to pane below |
| `ctrl-w k` | Navigate Up | Move to pane above |
| `ctrl-w l` | Navigate Right | Move to right pane |
| `ctrl-w v` | Vertical Split | Split pane vertically |
| `ctrl-w s` | Horizontal Split | Split pane horizontally |
| `ctrl-w q` | Close Pane | Close active pane/item |
| `ctrl-w o` | Close Others | Close all other panes |
| `ctrl-w w` | Next Pane | Cycle to next pane |
| `ctrl-w p` | Previous Pane | Cycle to previous pane |

## Quick Pane Access

| Keybinding | Action | Description |
|------------|--------|-------------|
| `cmd-1` | Pane 1 | Jump to pane 1 |
| `cmd-2` | Pane 2 | Jump to pane 2 |
| `cmd-3` | Pane 3 | Jump to pane 3 |
| `cmd-4` | Pane 4 | Jump to pane 4 |
| `cmd-5` | Pane 5 | Jump to pane 5 |
| `cmd-6` | Pane 6 | Jump to pane 6 |
| `cmd-7` | Pane 7 | Jump to pane 7 |
| `cmd-8` | Pane 8 | Jump to pane 8 |
| `cmd-9` | Pane 9 | Jump to pane 9 |

## Multi-cursor Workflows

| Keybinding | Action | Description |
|------------|--------|-------------|
| `cmd-d` | Select Next | Select next occurrence of selection |
| `cmd-shift-l` | Select All Matches | Select all occurrences |
| `alt-enter` | Split to Lines | Create cursor on each line |

## Layout & Focus

| Keybinding | Action | Description |
|------------|--------|-------------|
| `cmd-shift-z` | Centered Layout | Toggle zen mode centered layout |
| `cmd-k z` | Zoom Pane | Maximize/restore active pane |

## Vim Mode Features

### Settings Enabled:
- ✅ Vim mode active
- ✅ Relative line numbers
- ✅ System clipboard integration
- ✅ Smart case find for f/t motions
- ✅ Toggle relative numbers in insert mode

### Leader Key:
- Leader = `space` (in vim mode)

### Example Workflows:

**Quick file open:**
1. `cmd-p` → type filename → select file
2. Or: `space space` → use built-in finder

**Git workflow:**
1. `cmd-shift-g` → opens lazygit
2. Stage, commit, push using lazygit TUI
3. Press `q` to close

**Multi-pane editing:**
1. `ctrl-w v` → split vertically
2. `ctrl-w l` → move to right pane
3. `cmd-p` → open another file
4. `ctrl-w h` → move back to left pane
5. `cmd-1` / `cmd-2` → quick jump between panes

**Multi-cursor editing:**
1. Select text
2. `cmd-d` repeatedly to select next occurrences
3. Edit all at once
4. Or: `cmd-shift-l` to select all at once

**Search and replace:**
1. `space s g` → project search
2. Type search term
3. Browse results
4. Use replace functionality

## Terminal Integration

### Tmux Auto-attach:
- Terminal automatically attaches to tmux session named after project directory
- Session persists across Zed restarts
- Use `ctrl-\`` to toggle terminal focus

### Example:
- Working in `/Users/seifhassan/dotfiles`
- Terminal creates/attaches to tmux session named `dotfiles`
- Full tmux functionality available (splits, windows, etc.)

## Tips & Tricks

1. **Outline with Context Search**: In symbol outline (`space s s`), add a space in your search query to search both symbol name AND context (e.g., "pub fn" to find all public functions)

2. **Buffer Search with Regex**: Use buffer search (`space s b`), enable regex, then `alt-enter` to select all matches

3. **Copy & Trim**: Select multi-line text, right-click → "Copy and Trim" for clean indented paste

4. **File Comparison**: In project panel, select two files, right-click → "Compare marked files"

5. **Auto-save**: Files auto-save after 1 second delay - no need to manually save

## Configuration Files

All configs symlinked from dotfiles:

- **Settings**: `~/dotfiles/zed/.config/zed/settings.json`
- **Keymap**: `~/dotfiles/zed/.config/zed/keymap.json`
- **Tasks**: `~/dotfiles/zed/.config/zed/tasks.json`

## Rollback

If needed, restore from backups:
```bash
cp ~/.config/zed/settings.json.backup ~/dotfiles/zed/.config/zed/settings.json
cp ~/.config/zed/keymap.json.backup ~/dotfiles/zed/.config/zed/keymap.json
```

---

**Last Updated**: December 21, 2024
**Zed Version**: Latest stable
**Configuration**: Vim power user optimized
