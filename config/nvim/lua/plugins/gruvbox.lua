---@type LazySpec
return {
  {
    "ellisonleao/gruvbox.nvim",
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
