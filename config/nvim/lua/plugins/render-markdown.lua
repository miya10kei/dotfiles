return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    ---@module 'render-markdown'
    opts = {
      enabled = false,
      file_types = { "markdown", "Avante" },
    },
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
