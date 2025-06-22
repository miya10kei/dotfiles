---@type LazySpec
return {
  {
    "Shougo/ddc.vim",
    event = "InsertEnter",
    config = function()
      require("ddc_source_lsp_setup").setup()

      vim.fn["ddc#custom#patch_global"]({
        ui = "pum",
        sources = {
          "copilot",
          "lsp",
          "around",
        },
        sourceOptions = {
          _ = {
            matchers = { "matcher_fuzzy" },
            sorters = { "sorter_fuzzy" },
            converters = { "converter_fuzzy" },
          },
          around = {
            mark = "[A]",
          },
          copilot = {
            mark = "[C]",
            matchers = {},
            minAutoCompleteLength = 0,
          },
          lsp = {
            forceCompletionPattern = ".w*|:w*|->w*",
            keywordPattern = "\\k+",
            mark = "[L]",
            sorters = { "sorter_lsp-kind" },
            converters = { "converter_kind_labels" },
          },
        },
        sourceParams = {
          around = {
            maxSize = 200,
            minLength = 2,
          },
          copilot = {
            copilot = "lua",
            max_items = 5,
          },
          lsp = {
            kindLabels = {
              Class = "c",
            },
            enableResolveItem = true,
            enableAdditionalTextEdit = true,
            confirmBehavior = "replace",
            -- snippetEngine = vim.fn["denops#callback#register"](function(body)
            --   require("luasnip").lsp_expand(body)
            -- end),
          },
        },
      })
      vim.fn["ddc#enable"]()

      local previewer = require("ddc_previewer_floating")
      previewer.setup({
        ui = "pum",
        max_width = 120,
        border = "double",
      })
      previewer.enable()
    end,
    dependencies = {
      -- ui
      "Shougo/pum.vim",
      "Shougo/ddc-ui-pum",
      -- source
      ---- Current Buffer Source
      "Shougo/ddc-source-around",
      ---- LSP Source
      "uga-rosa/ddc-source-lsp-setup",
      "Shougo/ddc-source-lsp",
      ---- Copilot Source
      "zbirenbaum/copilot.lua",
      "Shougo/ddc-source-copilot",
      ---- Snipeet
      "L3MON4D3/LuaSnip",
      -- matcher
      "tani/ddc-fuzzy",
      -- sorter
      "Shougo/ddc-sorter_rank",
      -- preview
      "uga-rosa/ddc-previewer-floating",
    },
  },
}
