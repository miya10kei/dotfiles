require("ddc_source_lsp_setup").setup()

vim.fn["ddc#custom#patch_global"]({
  ui = "native",
  sources = {
    "around",
    "lsp",
    "vsnip",
  },
  sourceOptions = {
    _ = {
      matchers = {
        "matcher_head",
      },
    },
    around = {
      mark = "[A]",
    },
    lsp = {
      dup = "keep",
      --forceCompletionPattern = ".w*|:w*|->w*",
      keywordPattern = "\\k+",
      mark = "[LSP]",
      sorters = {
        "sorter_lsp-kind",
      },
    },
    vsnip = {
      forceCompletionPattern = ".w*|:w*|->w*",
      mark = "[vsnip]",
    },
  },
  sourceParams = {
    around = {
      maxSize = 500,
    },
    ["lsp"] = {
      kindLabels = {
        Class = "c",
      },
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      confirmBehavior = "replace",
      snippetEngine = vim.fn["denops#callback#register"](function(body)
        return vim.fn["vsnip#anonymous"](body)
      end),
    },
  },
})
vim.fn["ddc#enable"]()
