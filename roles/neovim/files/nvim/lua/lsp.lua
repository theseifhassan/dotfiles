-- Native LSP (Neovim 0.11+). Server *configs* ship with nvim-lspconfig (its
-- lsp/*.lua files, auto-discovered on the runtimepath); we only override what
-- we care about and enable the ones we use. The server binaries themselves are
-- installed outside the editor — see the `neovim` Ansible role.

-- Per-server overrides (everything else uses nvim-lspconfig defaults).
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ 'lua_ls', 'vtsls', 'eslint', 'yamlls', 'marksman' })

-- Diagnostics UI.
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.INFO] = '»',
      [vim.diagnostic.severity.HINT] = '⚑',
    },
  },
})

-- Native insert-mode completion driven by the LSP (no completion plugin).
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Enable native LSP completion',
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
