-- Editor options.
local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false

-- Indentation: 2 spaces (ts/js/yaml/md/lua).
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

-- Search.
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- Behaviour.
o.undofile = true
o.swapfile = false
o.clipboard = 'unnamedplus'
o.mouse = 'a'
o.splitright = true
o.splitbelow = true
o.termguicolors = true
o.updatetime = 250
o.timeoutlen = 400
o.confirm = true

-- Floating-window borders for hover / signature / diagnostics (0.11+).
o.winborder = 'rounded'

-- Native completion (Neovim 0.12) — driven by the LSP, no completion plugin.
o.completeopt = 'menu,menuone,noselect,fuzzy,popup'
o.pumheight = 12
