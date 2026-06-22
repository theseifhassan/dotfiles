-- Treesitter (main branch). Needs the tree-sitter CLI to compile parsers (the
-- `neovim` role installs tree-sitter-cli). The main branch does NOT auto-enable
-- highlighting via setup() — we start it per filetype.
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

local TS_LANGS = {
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"query",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

require("nvim-treesitter").install(TS_LANGS)

vim.api.nvim_create_autocmd("FileType", {
	desc = "Start Treesitter highlighting",
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end,
})
