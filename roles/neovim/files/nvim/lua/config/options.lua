-- Options — loaded before lazy.nvim startup, on top of LazyVim's defaults
-- (which already cover relativenumber, 2-space indent, ignorecase/smartcase,
-- undofile, system clipboard, splits right/below, termguicolors, ...).

-- Telescope as the picker (LazyVim auto-imports the editor.telescope extra
-- for it) instead of the snacks picker default.
vim.g.lazyvim_picker = "telescope"

local o = vim.opt

o.colorcolumn = "80"
o.scrolloff = 8 -- LazyVim defaults to 4
o.swapfile = false -- undofile (on by default) covers recovery

-- LazyVim disables clipboard sync in SSH sessions (SSH_CONNECTION check), but
-- this config runs on the server over SSH — force it; Neovim's built-in OSC52
-- support carries yanks back to the client's clipboard.
o.clipboard = "unnamedplus"
