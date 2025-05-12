---@type LazySpec
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    keys = {
      {
        "<C-m>",
        function()
          require("render-markdown").buf_toggle()
        end,
        silent = true,
      },
    },
  },
}
