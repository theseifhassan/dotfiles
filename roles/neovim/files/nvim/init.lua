-- Neovim config — owned, minimal, Neovim 0.12+.
-- Core: vim.pack (plugin manager) + native LSP + native completion.
-- Each plugin lives in its own lua/plugins/<name>.lua module that owns its
-- vim.pack.add, setup, and keymaps. Global (non-plugin) settings and keymaps
-- live under lua/config/.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Generic build step: any plugin that ships a Makefile (e.g.
-- telescope-fzf-native) gets `make` run on install/update. Registered BEFORE
-- any vim.pack.add so the initial install event is caught.
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Run `make` for plugins that ship a Makefile',
  callback = function(ev)
    if (ev.data.kind == 'install' or ev.data.kind == 'update')
      and vim.uv.fs_stat(ev.data.path .. '/Makefile') then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
  end,
})

require('config.options')

-- Plugins — each module is self-contained (add + setup + keymaps).
require('plugins.tokyonight')
require('plugins.treesitter')
require('plugins.lsp')
require('plugins.conform')
require('plugins.telescope')
require('plugins.harpoon')
require('plugins.gitsigns')
require('plugins.oil')
require('plugins.undotree')
require('plugins.surround')
require('plugins.mini')

require('config.keymaps')
