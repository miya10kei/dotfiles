---@type LazySpec
return {
  {
    "KEY60228/reviewthem.nvim",
    dependencies = {
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      ui = "telescope",
    },
  },
}
