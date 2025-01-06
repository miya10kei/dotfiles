require("ddc_source_lsp_setup").setup()

vim.fn["ddc#custom#patch_global"]({
  ui = "pum",
  sources = {
    "around",
    "lsp",
    -- "vsnip",
    "copilot",
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
    copilot = {
      mark = "[Copilot]",
      matchers = {},
      minAutoCompleteLength = 0,
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
    --   vsnip = {
    --     forceCompletionPattern = ".w*|:w*|->w*",
    --     mark = "[vsnip]",
    --   },
  },
  sourceParams = {
    -- around = {
    --   maxSize = 500,
    -- },
    ["lsp"] = {
      kindLabels = {
        Class = "c",
      },
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      confirmBehavior = "replace",
      -- snippetEngine = vim.fn["denops#callback#register"](function(body)
      --   return vim.fn["vsnip#anonymous"](body)
      -- end),
    },
  },
})
vim.fn["ddc#enable"]()

local ddc_previewer_floating = require("ddc_previewer_floating")
ddc_previewer_floating.setup({
  ui = "pum",
  max_width = 78,
  ...,
})
ddc_previewer_floating.enable()
