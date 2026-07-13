-- Formatting: biome for code, prettier for what biome doesn't cover
-- (yaml/markdown). Stylua for lua is a LazyVim default. Deliberately NOT the
-- biome/prettier extras — they overlap on js/ts/json; this keeps the split
-- explicit.
return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				javascript = { "biome" },
				javascriptreact = { "biome" },
				typescript = { "biome" },
				typescriptreact = { "biome" },
				json = { "biome" },
				jsonc = { "biome" },
				css = { "biome" },
				-- prettierd only — plain prettier isn't installed, so a
				-- fallback to it could never work.
				yaml = { "prettierd" },
				markdown = { "prettierd" },
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "biome", "prettierd" } },
	},
}
