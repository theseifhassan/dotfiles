-- Statusline configuration
return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = false,
      },
      sections = {
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
