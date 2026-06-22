-- Colorscheme.
vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

require("tokyonight").setup({
	style = "night",
	transparent = true,
	styles = {
		sidebars = "transparent", -- style for sidebars, see below
		floats = "transparent", -- style for floating windows
	},
})
vim.cmd.colorscheme("tokyonight")
