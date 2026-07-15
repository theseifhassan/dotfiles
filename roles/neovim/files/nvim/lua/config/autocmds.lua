-- Autocmds — loaded on VeryLazy, on top of LazyVim's defaults
-- (https://www.lazyvim.org/configuration/general#auto-commands).

-- Follow the terminal's light/dark mode (see plugins/colorscheme.lua).
-- Neovim only queries the terminal background once at startup, so re-ask on
-- focus (needs tmux focus-events); the built-in TermResponse handler updates
-- 'background' and we swap the tokyonight variant to match.
local group = vim.api.nvim_create_augroup("background_follows_terminal", {})

vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
	group = group,
	callback = function()
		pcall(vim.api.nvim_ui_send, "\027]11;?\007")
	end,
})

vim.api.nvim_create_autocmd("OptionSet", {
	group = group,
	pattern = "background",
	callback = function()
		local want = vim.o.background == "light" and "tokyonight-day" or "tokyonight-night"
		if vim.g.colors_name ~= want then
			vim.cmd.colorscheme(want)
		end
	end,
})
