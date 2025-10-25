---@type LazySpec
return {
  {
    'pwntester/octo.nvim',
    enable = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ibhagwan/fzf-lua',
      'nvim-tree/nvim-web-devicons',
    },
    opts={
      picker="fzf-lua"
    }
  }
}
