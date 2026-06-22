-- Global, non-plugin keymaps. (Leader is set in init.lua.)
-- Plugin-specific keymaps live in each plugin's module under lua/plugins/.
local map = vim.keymap.set

-- General / quality-of-life.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("x", "<leader>p", '"_dP', { desc = "Paste over selection (keep register)" })
map({ "n", "x" }, "<leader>d", '"_d', { desc = "Delete to black-hole register" })
map("n", "Q", "<nop>", { desc = "Disable Ex mode" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file e[X]ecutable", silent = true })
map(
	"n",
	"<leader>S",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[S]ubstitute word under cursor (file)" }
)

-- Files and buffers. (Window navigation stays on the native <C-w> h/j/k/l.)
map("n", "<leader>w", "<cmd>write<cr>", { desc = "[W]rite file" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "[B]uffer [D]elete" })
