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
      keymaps = {
        start_review = "<leader>rs",
        add_comment = "<leader>rc",
        submit_review = "<leader>rS",
        abort_review = "<leader>ra",
        show_comments = "<leader>rl",
        toggle_reviewed = "<leader>rm",
        show_status = "<leader>rp",
      },
    },
  },
}
