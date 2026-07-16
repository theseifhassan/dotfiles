-- Follow the terminal's light/dark mode: Neovim detects the background via
-- OSC 11 and sets 'background'; we only ever read it. Writing it (e.g. by
-- forcing style = "night") makes Neovim delete its detection autocmd at
-- VimEnter. Re-query-on-focus lives in config/autocmds.lua.
return {
	{
		"folke/tokyonight.nvim",
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				vim.cmd.colorscheme(vim.o.background == "light" and "tokyonight-day" or "tokyonight-night")
			end,
		},
	},
}
