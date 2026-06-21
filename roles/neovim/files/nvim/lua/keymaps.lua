-- Keymaps. (Leader is set in init.lua before plugins load.)
local map = vim.keymap.set

-- File explorer (oil — edit the filesystem like a buffer).
map('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory (oil)' })

-- Telescope.
local tb = require('telescope.builtin')
map('n', '<leader><leader>', tb.find_files, { desc = 'Find files' })
map('n', '<leader>sf', tb.find_files, { desc = '[S]earch [F]iles' })
map('n', '<leader>sg', tb.live_grep, { desc = '[S]earch by [G]rep' })
map('n', '<leader>sb', tb.buffers, { desc = '[S]earch [B]uffers' })
map('n', '<leader>sh', tb.help_tags, { desc = '[S]earch [H]elp' })
map('n', '<leader>sd', tb.diagnostics, { desc = '[S]earch [D]iagnostics' })
map('n', '<leader>sr', tb.resume, { desc = '[S]earch [R]esume' })

-- LSP — complements Neovim 0.11+ defaults (K hover, grn rename, gra code
-- action, grr references, gO document symbols).
map('n', 'gd', vim.lsp.buf.definition, { desc = '[G]oto [D]efinition' })
map('n', 'gD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
map('n', 'gi', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })
map('n', '<leader>f', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = '[F]ormat buffer' })

-- Native pmenu navigation (completion is built-in, so wire Tab/CR ourselves).
map('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })
map('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })
map('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

-- Ctrl-h/j/k/l moves seamlessly between nvim splits and tmux panes; the
-- vim-tmux-navigator plugin creates those mappings automatically (matched by
-- the companion bindings in the tmux role's tmux.conf).
