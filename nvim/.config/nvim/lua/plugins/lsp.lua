return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable({ "lua_ls", "ts_ls", "tailwindcss", "marksman", "yamlls", "jsonls", "biome", "bashls" })
        end
    },
}
