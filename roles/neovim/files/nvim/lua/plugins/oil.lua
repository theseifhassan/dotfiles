-- File management as an editable buffer.
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({ view_options = { show_hidden = true } })

vim.keymap.set("n", "<leader>pv", "<cmd>Oil<cr>", { desc = "[P]roject [V]iew (oil)" })

-- :Ex opens Oil (oil replaces netrw, so netrw's :Ex/:Explore are gone).
vim.api.nvim_create_user_command("Ex", "Oil", { desc = "Open Oil (netrw-style)" })
