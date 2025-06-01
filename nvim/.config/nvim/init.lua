require("config.lazy")

-- options
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.laststatus = 3
vim.opt.showmode = false

vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.cc = "80"
vim.g.virtcolumn_char = "|"
vim.g.virtcolumn_priority = 10
vim.opt.scrolloff = 10

vim.opt.clipboard = "unnamed"

vim.opt.inccommand = "split"

vim.opt.formatoptions:remove("o")

vim.opt.confirm = true
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.splitbelow = true
vim.opt.splitright = true

-- keymaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")              -- Move selected area down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")              -- Move selected area up
vim.keymap.set("x", "<leader>p", [["_dP]])                -- Paste & forget
vim.keymap.set("n", "<Esc><Esc>", "<CMD>nohlsearch<CR>")  -- Clear search highlights
vim.keymap.set("n", "<leader>pv", "<CMD>Oil --float<CR>") -- Clear search highlights

-- autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightYank", {}),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "incSearch",
			timeout = 40,
		})
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		-- Keymaps
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({
				border = "rounded",
			})
		end, { buffer = args.buf })
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({
				count = 1,
				float = {
					border = "rounded",
				},
			})
		end)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
				float = {
					border = "rounded",
				},
			})
		end)
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action)

		-- Autocmds
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		---@diagnostic disable-next-line: param-type-mismatch
		if client:supports_method("textDocument/formatting", 0) then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
				end,
			})
		end
	end,
})
