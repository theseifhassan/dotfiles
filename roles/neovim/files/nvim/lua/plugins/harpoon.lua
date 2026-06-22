-- Harpoon — pin a handful of files and jump between them instantly.
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim", -- dependency (shared with telescope)
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")
harpoon:setup()

local map = vim.keymap.set
map("n", "<leader>a", function()
	harpoon:list():add()
end, { desc = "Harpoon: [A]dd file" })
map("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: menu" })
map("n", "<leader>1", function()
	harpoon:list():select(1)
end, { desc = "Harpoon: file 1" })
map("n", "<leader>2", function()
	harpoon:list():select(2)
end, { desc = "Harpoon: file 2" })
map("n", "<leader>3", function()
	harpoon:list():select(3)
end, { desc = "Harpoon: file 3" })
map("n", "<leader>4", function()
	harpoon:list():select(4)
end, { desc = "Harpoon: file 4" })
