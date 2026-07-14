-- Tokyonight is LazyVim's default colorscheme; switch it to the night style
-- and make it composite with the terminal background.
return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
}
