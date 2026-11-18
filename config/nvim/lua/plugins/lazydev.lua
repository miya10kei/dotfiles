-- nvimのLua設定を書くときに、lua_ls が参照するライブラリ（$VIMRUNTIME や require したプラグイン）を自動で設定する
---@type LazySpec
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- `vim.uv` が出てきたときだけ luv の型を読み込む
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
