-- Plugins via Neovim 0.12's built-in vim.pack.
--
-- IMPORTANT: PackChanged build hooks must be registered BEFORE the first
-- vim.pack.add() call — the lockfile's presence changes when the install event
-- fires, so hooks defined afterwards miss the initial install.

local TS_LANGS = {
  'bash', 'css', 'html', 'javascript', 'json', 'lua', 'markdown',
  'markdown_inline', 'query', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
}

-- telescope-fzf-native needs a `make` step after it's installed/updated.
-- (Treesitter parsers are handled by the install() call below, which runs once
-- the plugin is on the runtimepath.)
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Build telescope-fzf-native after install/update',
  callback = function(ev)
    if ev.data.spec.name == 'telescope-fzf-native.nvim'
      and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
  end,
})

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/folke/tokyonight.nvim',
})

-- Colorscheme.
require('tokyonight').setup({ style = 'night' })
vim.cmd.colorscheme('tokyonight')

-- Treesitter (main branch): ensure parsers exist, start highlighting per
-- filetype. The main branch does NOT auto-enable highlighting via setup().
require('nvim-treesitter').install(TS_LANGS)
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Start Treesitter highlighting',
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- Small, focused plugins.
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.statusline').setup()
require('gitsigns').setup()
require('oil').setup({ view_options = { show_hidden = true } })

-- Formatting (prettier for web/config files, stylua for lua).
require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettierd', 'prettier', stop_after_first = true },
    jsonc = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    lua = { 'stylua' },
  },
  format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
})

-- Fuzzy finder.
require('telescope').setup({})
pcall(require('telescope').load_extension, 'fzf')
