-- ライブラリ（$VIMRUNTIME やプラグイン）の読み込みは lazydev.nvim に任せる
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
    },
  },
}
