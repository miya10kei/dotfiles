---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<Leader>c", group = "[claude]" },
        { "<Leader>u", group = "[ufo]" },
        { "<Leader>m", group = "Memo" },
        { "<Leader>w", group = "Workspace" },
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
