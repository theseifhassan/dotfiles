-- Git gutter signs + hunk actions.
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gs = require("gitsigns")
gs.setup()

local map = vim.keymap.set
map("n", "]h", function()
	gs.nav_hunk("next")
end, { desc = "Next git hunk" })
map("n", "[h", function()
	gs.nav_hunk("prev")
end, { desc = "Prev git hunk" })
map("n", "<leader>hs", gs.stage_hunk, { desc = "[H]unk [S]tage" })
map("n", "<leader>hr", gs.reset_hunk, { desc = "[H]unk [R]eset" })
map("n", "<leader>hp", gs.preview_hunk, { desc = "[H]unk [P]review" })
map("n", "<leader>hb", function()
	gs.blame_line({ full = true })
end, { desc = "[H]unk [B]lame line" })
