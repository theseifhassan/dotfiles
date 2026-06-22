-- Fuzzy finder. fzf-native is compiled by the Makefile build hook in init.lua.
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})

require("telescope").setup({})
pcall(require("telescope").load_extension, "fzf")

-- Transparency: the border cells (the areas between and around the prompt,
-- results, and preview panes) composite fully into the editor buffer behind
-- them via the per-highlight `blend` attribute, while the panes themselves
-- (TelescopeNormal & friends) are left untouched and stay opaque. Pure Neovim,
-- no terminal opacity. Reapplied on ColorScheme so a theme switch can't reset it.
local function telescope_transparent()
	for _, group in ipairs({
		"TelescopeBorder",
		"TelescopePromptBorder",
		"TelescopeResultsBorder",
		"TelescopePreviewBorder",
		"TelescopeTitle",
		"TelescopePromptTitle",
		"TelescopeResultsTitle",
		"TelescopePreviewTitle",
	}) do
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.blend = 100
		vim.api.nvim_set_hl(0, group, hl)
	end
end
telescope_transparent()
vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Keep Telescope borders transparent",
	callback = telescope_transparent,
})

local tb = require("telescope.builtin")
local map = vim.keymap.set
map("n", "<leader><leader>", tb.find_files, { desc = "Find files" })
map("n", "<leader>sf", tb.find_files, { desc = "[S]earch [F]iles" })
map("n", "<leader>sg", tb.live_grep, { desc = "[S]earch by [G]rep" })
map("n", "<leader>sb", tb.buffers, { desc = "[S]earch [B]uffers" })
map("n", "<leader>sh", tb.help_tags, { desc = "[S]earch [H]elp" })
map("n", "<leader>sd", tb.diagnostics, { desc = "[S]earch [D]iagnostics" })
map("n", "<leader>sr", tb.resume, { desc = "[S]earch [R]esume" })
