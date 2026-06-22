-- Native LSP (Neovim 0.11+). Server configs ship with nvim-lspconfig (its
-- lsp/*.lua files, auto-discovered on the runtimepath); we override what we
-- care about and enable the ones we use. Server binaries are installed outside
-- the editor (see the `neovim` role: brew + mise). Completion is native too.
vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

local map = vim.keymap.set

-- Per-server overrides (everything else uses nvim-lspconfig defaults).
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.enable({ "lua_ls", "vtsls", "eslint", "yamlls", "marksman" })

-- Diagnostics UI.
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded" },
})

-- LSP keymaps — complement Neovim 0.11+ defaults (K hover, grn rename, gra code
-- action, grr references, gO document symbols).
map("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "[G]oto [I]mplementation" })

-- Diagnostics ([d / ]d to jump are Neovim defaults).
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Native insert-mode completion driven by the LSP (no completion plugin).
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Enable native LSP completion",
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- pmenu navigation (completion is built-in, so wire Tab/CR ourselves).
map("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
map("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })
map("i", "<CR>", function()
	return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true })
