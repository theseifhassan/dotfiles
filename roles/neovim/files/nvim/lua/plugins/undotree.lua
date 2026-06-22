-- Visual, navigable undo-history tree (pairs with persistent undofile).
vim.pack.add({ "https://github.com/mbbill/undotree" })

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "[U]ndotree toggle" })
