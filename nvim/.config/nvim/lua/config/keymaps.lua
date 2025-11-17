vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")       -- Move selected area down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")       -- Move selected area up
vim.keymap.set("x", "<leader>p", [["_dP]])         -- Paste & forget
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]) -- Copy selected to system clipbaord
vim.keymap.set("n", "<leader>Y", [["+Y]])          -- Copy line to system clipboard
vim.keymap.set("n", "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
)                                 -- Search & Replace for CWD
vim.keymap.set("n", "J", "mzJ`z") -- Keep me right there
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<Esc><Esc>", "<CMD>nohlsearch<CR>") -- Clear search highlights
