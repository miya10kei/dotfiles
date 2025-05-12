---@type LazySpec
return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      contrast = "soft",
    },
    config = function()
      vim.cmd([[
        colorscheme gruvbox
      ]])
    end,
  },
}
