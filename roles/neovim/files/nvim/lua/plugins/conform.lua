-- Formatting. biome for code, prettier for yaml/markdown, stylua for lua.
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
	formatters_by_ft = {
		-- biome handles js/ts/jsx/tsx/json/jsonc/css (not yaml/markdown).
		javascript = { "biome" },
		javascriptreact = { "biome" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
		css = { "biome" },
		-- biome doesn't cover yaml/markdown, so prettier handles just those two.
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua" },
	},
	format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
