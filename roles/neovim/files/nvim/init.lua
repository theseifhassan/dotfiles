-- Neovim config — owned, minimal, Neovim 0.12+.
-- Built on core: vim.pack (plugin manager) + native LSP (vim.lsp.config/enable)
-- + native insert-mode completion. No distro, no Mason, no completion plugin.
-- Deployed by the `neovim` Ansible role, which also installs the language
-- servers (brew + mise npm backend).

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options')
require('plugins')
require('lsp')
require('keymaps')
