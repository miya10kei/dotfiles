---@type LazySpec
return {
  {
    "greggh/claude-code.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    opts = {},
  },
}
