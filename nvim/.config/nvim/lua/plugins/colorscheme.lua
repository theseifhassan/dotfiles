return {
    {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        enabled = false,
        config = function()
            require("rose-pine").setup {
                styles = {
                    italic = false,
                    transparency = true,
                }
            }
            -- load the colorscheme here
            vim.cmd([[colorscheme rose-pine]])
        end,
    },
    {

        "https://github.com/ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("gruvbox").setup {
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                },
                transparent_mode = true,
            }
            -- load the colorscheme here
            vim.cmd([[colorscheme gruvbox]])
        end,

    }
}
