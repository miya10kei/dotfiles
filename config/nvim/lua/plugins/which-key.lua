---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<Leader>u", group = "[ufo]" },
      },
      win = {
        row = 0.5,
        col = 0.5,
        width = { max = 300 },
        border = "rounded",
      },
    },
  },
}
