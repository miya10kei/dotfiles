---@type LazySpec
return {
  {
    "rebelot/kanagawa.nvim",
    enabled = true,
    opts = {
      theme = "wave",
    },
    config = function()
      vim.cmd("colorscheme kanagawa")
    end,
  },
}
