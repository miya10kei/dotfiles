-- サーバーの既定値は nvim-lspconfig の lsp/<name>.lua、上書きは after/lsp/<name>.lua に置く
-- 補完のcapabilitiesは blink.cmp が vim.lsp.config("*") へ自動で登録する
local servers = {
  "bashls",
  "docker_compose_language_service",
  "docker_language_server",
  "html",
  "jsonls",
  "kotlin_lsp",
  "lua_ls",
  "marksman",
  "pyright",
  "rust_analyzer",
  "taplo",
  "terraformls",
  "ts_ls",
  "yamlls",
}

---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "ibhagwan/fzf-lua",
      "saghen/blink.cmp",
      "folke/which-key.nvim",
    },
    config = function()
      local function fzf(name)
        return function()
          require("fzf-lua")[name]()
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          require("which-key").add({
            { "<Leader>l", group = "LSP", buffer = bufnr },
            { "<Leader>ln", group = "Navigation", buffer = bufnr },
            { "<Leader>lv", group = "View", buffer = bufnr },
            { "<Leader>le", group = "Edit", buffer = bufnr },
            -- ナビゲーション
            { "gd", fzf("lsp_definitions"), desc = "Definition", buffer = bufnr, silent = true },
            { "gh", fzf("lsp_incoming_calls"), desc = "Incoming Calls", buffer = bufnr, silent = true },
            { "gi", fzf("lsp_implementations"), desc = "Implementation", buffer = bufnr, silent = true },
            { "gw", fzf("lsp_workspace_symbols"), desc = "Workspace Symbols", buffer = bufnr, silent = true },
            { "<Leader>lno", fzf("lsp_outgoing_calls"), desc = "Outgoing Calls", buffer = bufnr, silent = true },
            -- 情報表示
            { "<Leader>lvs", vim.lsp.buf.signature_help, desc = "Signature Help", buffer = bufnr, silent = true },
            -- 編集
            {
              "<Leader>lef",
              function()
                vim.lsp.buf.format({ async = true })
              end,
              desc = "Format",
              buffer = bufnr,
              silent = true,
              mode = { "n", "x" },
            },
          })
        end,
      })

      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        virtual_text = {
          format = function(d)
            local detail = vim.tbl_filter(function(s)
              return s ~= nil and s ~= ""
            end, { d.source, d.code and tostring(d.code) or nil })
            if #detail == 0 then
              return d.message
            end
            return string.format("%s (%s)", d.message, table.concat(detail, ": "))
          end,
        },
        -- [d / ]d（標準のキーマップ）で移動したら、その診断をフロートで表示する
        jump = {
          on_jump = function(diagnostic, bufnr)
            if diagnostic then
              vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
            end
          end,
        },
      })

      vim.lsp.enable(servers)
    end,
    keys = {
      { "<Leader>e", vim.diagnostic.open_float, desc = "Show diagnostics" },
      { "<Leader>q", vim.diagnostic.setloclist, desc = "Set diagnostic to loclist" },
    },
  },
}
