---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    main = "lsp",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      ---------------
      --- Keymaps ---
      ---------------
      local keymap = vim.keymap.set

      local on_attach = function(_, bufnr)
        local bufopts = { buffer = bufnr, silent = true }
        keymap("n", "gD", vim.lsp.buf.declaration, bufopts)
        keymap("n", "K", vim.lsp.buf.hover, bufopts)
        keymap("n", "gi", vim.lsp.buf.implementation, bufopts)
        keymap("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        keymap("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        keymap("n", "<Leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        keymap("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
        keymap("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
        keymap("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
      end

      require("mason-lspconfig").setup()
      local mason_registry = require("mason-registry")

      ----------------
      --- nvim-lsp ---
      ----------------
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        virtual_text = {
          format = function(d)
            return string.format("%s (%s: %s)", d.message, d.source, d.code)
          end,
        },
      })
      ----------------------
      --- nvim-lspconfig ---
      ----------------------
      local capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      }

      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- グローバルLSP設定
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      local used_mason_packages = {
        "angular-language-server",
        "bash-language-server",
        "docker-compose-language-service",
        "docker-language-server",
        "gopls",
        "haskell-language-server",
        "html-lsp",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "pyright",
        "rust-analyzer",
        "terraform-ls",
        "typescript-language-server",
        "yaml-language-server",
      }

      -- Mason パッケージ名から lspconfig の設定名へのマッピング
      local mason_to_lsp = {
        ["angular-language-server"] = "angularls",
        ["bash-language-server"] = "bashls",
        ["docker-compose-language-service"] = "docker_compose_language_service",
        ["docker-language-server"] = "docker_lsp",
        ["haskell-language-server"] = "hls",
        ["html-lsp"] = "html",
        ["json-lsp"] = "jsonls",
        ["lua-language-server"] = "lua_ls",
        ["rust-analyzer"] = "rust_analyzer",
        ["terraform-ls"] = "terraformls",
        ["typescript-language-server"] = "ts_ls",
      }

      -- LSPサーバー個別設定
      local lsp_settings = {
        -- リンティングはRuffに任せ、型チェックに特化
        pyright = {
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
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = {
                  vim.fn.expand("$VIMRUNTIME/lua"),
                  vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                  vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                  vim.fn.stdpath("data") .. "/lazy/blink.cmp",
                },
              },
              telemetry = { enable = false },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              import = { granularity = { group = "module" } },
              prefix = "self",
            },
            cargo = { buildScripts = { enable = true } },
            procMacro = { enable = true },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              format = { enable = false },
              schemas = {
                ["https://json.schemastore.org/github-action.json"] = ".github/actions/*.yaml",
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yaml",
                ["https://raw.githubusercontent.com/aws/aws-sam-cli/master/schema/samcli.json"] = "samconfig.yaml",
                ["https://raw.githubusercontent.com/aws/serverless-application-model/develop/samtranslator/validator/sam_schema/schema.json"] = "template*.yaml",
              },
            },
          },
        },
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
        },
      }

      -- LSPサーバーの設定と有効化
      for _, v in ipairs(used_mason_packages) do
        local alias = mason_to_lsp[v] or mason_registry.get_package_aliases(v)[1] or v
        if lsp_settings[alias] then
          vim.lsp.config(alias, lsp_settings[alias])
        end
        vim.lsp.enable(alias)
      end
    end,
    keys = {
      {
        "<Leader>e",
        vim.diagnostic.open_float,
        desc = "Show diagnostics",
      },
      {
        "[d",
        function()
          vim.diagnostic.jump({ count = -1, float = true })
        end,
        desc = "Go to previous diagnostic",
      },
      {
        "]d",
        function()
          vim.diagnostic.jump({ count = 1, float = true })
        end,
        desc = "Go to next diagnostic",
      },
      {
        "<Leader>q",
        vim.diagnostic.setloclist,
        desc = "Set diagnostic to loclist",
      },
    },
  },
}
