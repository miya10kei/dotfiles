---@type LazySpec
return {
  {
    "ellisonleao/gruvbox.nvim",
    enabled = false,
    opts = {
      contrast = "hard",
    },
    config = function()
      vim.cmd([[
        colorscheme gruvbox
      ]])
    end,
  },
}
