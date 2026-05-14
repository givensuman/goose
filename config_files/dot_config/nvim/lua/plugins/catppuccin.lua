return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    -- opts = function(_, opts)
    --   opts.transparent_background = true
    --   return opts
    -- end,
  },
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
          opts.highlights = require("catppuccin.special.bufferline").get_theme()
        end
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
