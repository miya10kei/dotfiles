---@type LazySpec
return {
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      keymaps = {
        init_selection = "<M-j>",
        node_incremental = "<M-j>",
        node_decremental = "<M-k>",
      },
    },
  },
}
