-- JetBrains公式のkotlin-lsp（mise の http:kotlin-lsp）。Claude Codeのkotlin-lspプラグインと同じバイナリを使う
---@type vim.lsp.Config
return {
  cmd = { "kotlin-lsp", "--stdio" },
}
