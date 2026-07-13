-- Keymaps — loaded on VeryLazy, on top of LazyVim's defaults
-- (https://www.lazyvim.org/keymaps): <esc> clears hlsearch, ]b/[b buffers,
-- <leader>bd delete buffer, <C-s> save, <leader><leader> find files, ...
-- Plugin-specific keymaps live in each plugin's spec under lua/plugins/.
local map = vim.keymap.set

-- Keep the cursor centered / in place.
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Move a visual selection up/down.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Register hygiene.
map("x", "<leader>p", '"_dP', { desc = "Paste over selection (keep register)" })
map({ "n", "x" }, "<leader>d", '"_d', { desc = "Delete to black-hole register" })

map("n", "Q", "<nop>", { desc = "Disable Ex mode" })
map("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { desc = "Make [F]ile e[X]ecutable", silent = true })
map(
	"n",
	"<leader>rw",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[R]eplace [W]ord under cursor (file)" }
)
