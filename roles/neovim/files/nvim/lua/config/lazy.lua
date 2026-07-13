-- Bootstrap lazy.nvim and load LazyVim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- Extras (must come after LazyVim, before our plugins).
		{ import = "lazyvim.plugins.extras.lang.typescript" }, -- vtsls
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.lang.yaml" }, -- yamlls
		{ import = "lazyvim.plugins.extras.lang.markdown" }, -- marksman
		{ import = "lazyvim.plugins.extras.linting.eslint" },
		{ import = "lazyvim.plugins.extras.editor.harpoon2" },
		{ import = "lazyvim.plugins.extras.coding.mini-surround" }, -- gsa/gsd/gsr
		-- Our overrides and additions.
		{ import = "plugins" },
	},
	defaults = { lazy = false, version = false },
	install = { colorscheme = { "tokyonight", "habamax" } },
	-- No update checker: lazy-lock.json is tracked in the dotfiles repo and
	-- the deployed config is an rsync'd copy, so machine-local updates would
	-- silently drift and be reverted by the next deploy. Update deliberately
	-- with :Lazy update in the repo, then commit the lockfile.
	checker = { enabled = false },
	performance = {
		rtp = {
			disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
		},
	},
})
