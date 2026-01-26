# Dotfiles Code Review - Action Items

> Generated: 2026-01-26
> Status: Pending review and implementation

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| Critical | 6 | Pending |
| High | 8 | Pending |
| Medium | 25+ | Pending |
| Low | 15+ | Pending |

---

## Critical Issues

### Security & Memory Safety

- [ ] **CRITICAL: Command injection in webappmgr.sh**
  - **File:** `scripts/.local/bin/webappmgr.sh:26-33`
  - **Issue:** Desktop file injection via unescaped URL in Exec= line
  - **Fix:** Escape special characters in `$url` before writing to .desktop file:
    ```bash
    # Before line 26, add:
    url_escaped=$(printf '%s' "$url" | sed "s/'/'\\\\''/g")
    # Then use: Exec=$BROWSER --app='$url_escaped'
    ```

- [ ] **CRITICAL: Unsafe rm -rf with variable expansion**
  - **File:** `scripts/.local/bin/dot:28`
  - **Issue:** `rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"` could delete wrong directory
  - **Fix:** Add guard before deletion:
    ```bash
    target="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
    [[ "$target" == */dotfiles ]] || { echo "Safety check failed"; exit 1; }
    rm -rf "$target"
    ```

- [ ] **CRITICAL: Buffer overflow in dwmblocks strncat()**
  - **File:** `dwmblocks/src/status.c:38,41,48,52-53,59`
  - **Issue:** `strncat()` uses source size instead of remaining destination space
  - **Fix:** Replace with `snprintf()` or calculate remaining buffer space:
    ```c
    // Instead of: strncat(status->current, block->icon, LEN(block->output));
    // Use: snprintf(status->current + strlen(status->current),
    //               sizeof(status->current) - strlen(status->current),
    //               "%s", block->icon);
    ```

- [ ] **CRITICAL: Hardcoded /tmp session file (symlink attack)**
  - **File:** `dwm/config.h:5`
  - **Issue:** `/tmp/dwm-session` is world-writable, vulnerable to symlink attacks
  - **Fix:** Use XDG_RUNTIME_DIR:
    ```c
    // Replace: #define SESSION_FILE "/tmp/dwm-session"
    // With runtime detection or: /run/user/UID/dwm-session
    ```

- [ ] **CRITICAL: Subshell variable scoping bug**
  - **File:** `scripts/.local/bin/dot:127-130`
  - **Issue:** While loop runs in subshell due to pipe, `$i` changes don't persist
  - **Fix:** Use process substitution or here-string:
    ```bash
    # Instead of: echo "$wallpapers" | while IFS= read -r w; do
    # Use: while IFS= read -r w; do ... done <<< "$wallpapers"
    ```

- [ ] **CRITICAL: Bootstrap circular dependency**
  - **File:** `zsh/.zshenv:2`
  - **Issue:** `DOTS_DEFAULT` used before it's defined (defined in sourced file)
  - **Fix:** Define DOTS_DEFAULT directly in .zshenv before sourcing:
    ```bash
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export DOTS_DEFAULT="$XDG_DATA_HOME/dotfiles"
    source "$HOME/dotfiles/default/zsh/envs.zsh"
    source "$DOTS_DEFAULT/zsh/path.zsh"
    ```

---

## High Priority Issues

### Security

- [ ] **Personal email exposed in git config**
  - **File:** `git/.config/git/config:2`
  - **Issue:** Email `theseifhassan@gmail.com` is in version control
  - **Fix:** Move to untracked local config:
    ```bash
    # git/.config/git/config - remove email, add:
    [include]
        path = ~/.gitconfig.local
    # Create ~/.gitconfig.local (untracked) with email
    ```

- [ ] **npx -y without version pinning**
  - **File:** `opencode/.config/opencode/opencode.json:18`
  - **Issue:** `npx -y next-devtools-mcp@latest` installs untrusted code without confirmation
  - **Fix:** Pin exact versions and remove `-y` flag:
    ```json
    "command": ["npx", "next-devtools-mcp@1.2.3"]
    ```

- [ ] **sudo in autorandr without proper handling**
  - **File:** `autorandr/.config/autorandr/postswitch.d/10-dpi-switch:28-29,41,49`
  - **Issue:** Multiple sudo calls that may fail or create privilege escalation
  - **Fix:** Document required sudoers entries or use systemd user services instead

### Deprecated APIs

- [ ] **TreeSitter uses deprecated `after` field**
  - **File:** `nvim/.config/nvim/lua/plugins/treesitter.lua:38`
  - **Issue:** `after = "nvim-treesitter"` is deprecated in lazy.nvim
  - **Fix:** Replace with `dependencies`:
    ```lua
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ```

- [ ] **vim.lsp.enable() bypasses LazyVim**
  - **File:** `nvim/.config/nvim/lua/plugins/lsp.lua:5`
  - **Issue:** Low-level LSP enable bypasses LazyVim's Mason integration
  - **Fix:** Use LazyVim's `opts.servers` pattern instead

- [ ] **Deprecated set-window-option in tmux**
  - **File:** `default/tmux/tmux.conf:19`
  - **Issue:** `set-window-option` deprecated since tmux 2.9
  - **Fix:** Replace with `setw -g mode-keys vi`

### Performance

- [ ] **Redundant FZF initialization**
  - **File:** `default/zsh/init.zsh:3-5`
  - **Issue:** Sources system fzf files, then runs `fzf --zsh` which does the same
  - **Fix:** Remove lines 3-4, keep only:
    ```bash
    command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)" 2>/dev/null
    ```

- [ ] **lazy.nvim defaults to lazy=false**
  - **File:** `nvim/.config/nvim/lua/config/lazy.lua:27`
  - **Issue:** All plugins load at startup instead of on-demand
  - **Fix:** Change to `lazy = true` and add explicit triggers to essential plugins

---

## Medium Priority Issues

### Dead Code & Cleanup

- [ ] **Delete example.lua template**
  - **File:** `nvim/.config/nvim/lua/plugins/example.lua`
  - **Action:** `rm nvim/.config/nvim/lua/plugins/example.lua`

- [ ] **Remove or enable snacks.nvim**
  - **File:** `nvim/.config/nvim/lua/plugins/snacks.lua`
  - **Issue:** All features disabled, plugin serves no purpose
  - **Action:** Either enable desired features or remove the file

- [ ] **Remove disabled treesitter-context**
  - **File:** `nvim/.config/nvim/lua/plugins/treesitter.lua:36-57`
  - **Issue:** Plugin is loaded then disabled
  - **Action:** Remove the entire second plugin spec block

- [ ] **Clean up disabled.lua**
  - **File:** `nvim/.config/nvim/lua/plugins/disabled.lua`
  - **Issue:** Plugins still initialize before being disabled
  - **Action:** Remove from lazy-lock.json or document why disabled

### Shell Script Hardening

- [ ] **Add set -e to all scripts**
  - **Files:** All scripts in `scripts/.local/bin/`
  - **Fix:** Add to top of each script:
    ```bash
    #!/bin/sh
    set -e
    ```

- [ ] **Add dependency checks to scripts**
  - **Files:** `screenshot.sh`, `floating-term`, `sessionizer.sh`, etc.
  - **Fix:** Check for required commands before use:
    ```bash
    command -v scrot >/dev/null || { echo "scrot required"; exit 1; }
    ```

- [ ] **Fix word splitting in sessionizer.sh**
  - **File:** `scripts/.local/bin/sessionizer.sh:10`
  - **Issue:** `$SEARCH_DIRS` unquoted, breaks with spaces in paths
  - **Fix:** Use array or proper quoting

- [ ] **Fix race condition in floating-term**
  - **File:** `scripts/.local/bin/floating-term:16`
  - **Issue:** Hard sleep before xdotool, may fail if window slow to appear
  - **Fix:** Loop with timeout waiting for window

- [ ] **Fix TOCTOU in webappmgr.sh**
  - **File:** `scripts/.local/bin/webappmgr.sh:45,56`
  - **Issue:** File could be deleted between grep and rm
  - **Fix:** Add existence check before rm

- [ ] **Fix command injection in dot packages**
  - **File:** `scripts/.local/bin/dot:94`
  - **Issue:** Package names not quoted in yay command
  - **Fix:** Use xargs or proper array handling

### Neovim Plugin Conflicts

- [ ] **Resolve Harpoon duplication**
  - **Files:** `lazyvim.json:4` and `nvim/lua/plugins/harpoon.lua`
  - **Issue:** LazyVim extra + custom config may conflict
  - **Fix:** Choose one approach - either use extra OR custom config

- [ ] **Resolve Telescope duplication**
  - **Files:** `lazyvim.json:5` and `nvim/lua/plugins/telescope.lua`
  - **Issue:** Same as Harpoon - extra + custom config
  - **Fix:** Consolidate into one configuration approach

- [ ] **Add keybinding descriptions**
  - **File:** `nvim/lua/plugins/harpoon.lua`
  - **Issue:** Keymaps lack descriptions for which-key
  - **Fix:** Add `{ desc = "..." }` to all vim.keymap.set calls

### Hardcoded Values

- [ ] **Extract DPI values to config**
  - **File:** `autorandr/.config/autorandr/postswitch.d/10-dpi-switch:7,11`
  - **Fix:** Create separate config file or use environment variables

- [ ] **Add font fallbacks**
  - **Files:** `ghostty/.config/ghostty/config:3`, `dunst/.config/dunst/dunstrc:28`
  - **Fix:** Add fallback fonts:
    ```
    font-family = "Berkeley Mono, JetBrains Mono, monospace"
    ```

- [ ] **Fix hardcoded battery path**
  - **File:** `scripts/.local/bin/dwmblock.battery.sh:3`
  - **Issue:** Assumes BAT0, some systems use BAT1
  - **Fix:** Iterate to find first battery

- [ ] **Remove hardcoded grep -P (non-POSIX)**
  - **File:** `scripts/.local/bin/dot:121`
  - **Issue:** Perl regex not available on all systems
  - **Fix:** Use POSIX-compatible regex or sed

### Missing Error Handling

- [ ] **Add error handling to LSP enable**
  - **File:** `nvim/lua/plugins/lsp.lua:4-6`
  - **Fix:** Wrap in pcall

- [ ] **Add sourcing error checks in zsh**
  - **Files:** All source commands in zsh configs
  - **Fix:** `source "$file" || echo "Failed to source $file" >&2`

- [ ] **Add error handling to autorandr script**
  - **File:** `autorandr/.config/autorandr/postswitch.d/10-dpi-switch`
  - **Fix:** Add `set -e` and trap for cleanup

### Consistency Issues

- [ ] **Standardize nvim plugin config pattern**
  - **Files:** All files in `nvim/lua/plugins/`
  - **Issue:** Mix of `config = function()` and `opts`
  - **Fix:** Use `opts` pattern consistently (LazyVim idiomatic)

- [ ] **Standardize quoting in TOML/Lua**
  - **Files:** `starship.toml`, nvim lua files
  - **Fix:** Use double quotes consistently

- [ ] **Fix starship username contradiction**
  - **File:** `starship/.config/starship.toml:13-17`
  - **Issue:** `show_always = true` but `disabled = true`
  - **Fix:** Remove section entirely or clarify intent

---

## Low Priority Issues

### Documentation

- [ ] **Add troubleshooting section to README**
- [ ] **Document DOTS_DEFAULT pattern**
- [ ] **Add directory-level READMEs** (opencode/, applications/, scripts/)
- [ ] **Document Arch Linux requirement prominently**
- [ ] **Add cross-platform limitations**

### Gitignore

- [ ] **Remove redundant .zcompdump entry** (line 28 duplicates line 3)
- [ ] **Add opencode/node_modules to gitignore**
- [ ] **Add *.orig files to gitignore**
- [ ] **Expand git ignore patterns** for local configs

### Code Style

- [ ] **Use consistent zsh test syntax** (`[[ ]]` vs `[ ]`)
- [ ] **Remove unused _opt variable** in nvim options.lua
- [ ] **Add comments explaining non-obvious configs**

### Tmux

- [ ] **Add clipboard fallback for Wayland** (wl-copy)
- [ ] **Configure tmux-resurrect** save directory and frequency
- [ ] **Document prefix key** (currently using default C-b)

### Picom

- [ ] **Consider switching backend** from glx to xr_glx_hybrid
- [ ] **Remove deprecated dbe option**
- [ ] **Document blur performance tradeoffs**

---

## Architecture Changes

### Migrate to Mise for Tool Management

- [ ] **Create global mise config**
  - **File:** `mise/.config/mise/config.toml`
  - **Content:**
    ```toml
    [tools]
    node = "lts"
    pnpm = "latest"
    go = "latest"
    # Add other tools currently in packages.txt
    ```

- [ ] **Remove packages.txt approach**
  - **Files:** `install/packages`, `install/setup.sh` package installation logic
  - **Action:** Replace with mise-based installation

- [ ] **Update dot command**
  - **File:** `scripts/.local/bin/dot`
  - **Action:** Add `dot tools` command that wraps `mise install`

- [ ] **Document mise workflow**
  - **File:** `README.md`
  - **Action:** Add section on using mise for tool management

### Consolidate Install Logic

- [ ] **Remove duplicate linking code**
  - **Files:** `install/setup.sh` and `scripts/.local/bin/dot`
  - **Action:** Keep logic in one place, have other call it

- [ ] **Add verification script**
  - **Action:** Create `dot verify` command to check symlinks and dependencies

- [ ] **Add uninstall script**
  - **Action:** Create `install/uninstall.sh` for cleanup

---

## Files to Delete

```bash
# Dead code
rm nvim/.config/nvim/lua/plugins/example.lua

# If not using clipboard system
rm scripts/.local/bin/clipd.sh
rm scripts/.local/bin/clipboard-clear.sh

# Suckless patch artifacts (if not needed)
rm dmenu/dmenu.c.orig
rm dmenu/config.mk.orig
```

---

## Testing Checklist

After implementing fixes:

- [ ] Fresh shell starts without errors
- [ ] Neovim opens without warnings
- [ ] Tmux sessions work with copy/paste
- [ ] DWM keybindings all functional
- [ ] autorandr profile switching works
- [ ] `dot update` completes successfully
- [ ] `dot link` is idempotent (can run twice)
- [ ] All dwmblocks status scripts produce output
