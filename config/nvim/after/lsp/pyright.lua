-- リンティングはRuffに任せ、型チェックに特化
---@type vim.lsp.Config
return {
  settings = {
    python = {
      analysis = {
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUnusedClass = "none",
          reportUnusedFunction = "none",
        },
      },
    },
  },
}
