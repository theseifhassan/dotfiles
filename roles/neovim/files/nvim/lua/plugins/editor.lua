-- Editor additions LazyVim doesn't ship: oil (file management as an editable
-- buffer) and undotree (visual undo history, pairs with persistent undofile).
return {
	{
		-- Snacks explorer also hijacks directory opens (replace_netrw); turn
		-- that off so oil is the only claimant. <leader>e still opens snacks
		-- explorer explicitly.
		"folke/snacks.nvim",
		opts = { explorer = { replace_netrw = false } },
	},
	{
		"stevearc/oil.nvim",
		lazy = false, -- so oil (not netrw/snacks) owns `nvim <dir>` opens
		opts = { view_options = { show_hidden = true } },
		keys = {
			{ "<leader>pv", "<cmd>Oil<cr>", desc = "[P]roject [V]iew (oil)" },
		},
		init = function()
			-- :Ex opens Oil (oil replaces netrw, so netrw's :Ex/:Explore are gone).
			vim.api.nvim_create_user_command("Ex", "Oil", { desc = "Open Oil (netrw-style)" })
		end,
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			-- <leader>u is LazyVim's UI-toggle prefix, so undotree gets <leader>U.
			{ "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "[U]ndotree toggle" },
		},
	},
}
