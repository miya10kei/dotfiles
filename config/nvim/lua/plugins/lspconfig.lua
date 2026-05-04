---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    main = "lsp",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
      "folke/which-key.nvim",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      local function fzf(name)
        return function()
          require("fzf-lua")[name]()
        end
      end

      ---------------
      --- Keymaps ---
      ---------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          require("which-key").add({
            -- グループ
            { "<Leader>l", group = "LSP", buffer = bufnr },
            { "<Leader>ln", group = "Navigation", buffer = bufnr },
            { "<Leader>lv", group = "View", buffer = bufnr },
            { "<Leader>le", group = "Edit", buffer = bufnr },
            -- ナビゲーション
            { "gd", fzf("lsp_definitions"), desc = "Definition", buffer = bufnr, silent = true },
            { "gh", fzf("lsp_incoming_calls"), desc = "Incoming Calls", buffer = bufnr, silent = true },
            { "gw", fzf("lsp_workspace_symbols"), desc = "Workspace Symbols", buffer = bufnr, silent = true },
            { "<Leader>lns", fzf("lsp_incoming_calls"), desc = "Incoming Calls", buffer = bufnr, silent = true },
            { "<Leader>lno", fzf("lsp_outgoing_calls"), desc = "Outgoing Calls", buffer = bufnr, silent = true },
            -- 情報表示
            { "<Leader>lvs", vim.lsp.buf.signature_help, desc = "Signature Help", buffer = bufnr, silent = true },
            { "<Leader>lve", vim.diagnostic.open_float, desc = "Diagnostic", buffer = bufnr, silent = true },
            -- 編集
            {
              "<Leader>lef",
              function()
                vim.lsp.buf.format({ async = true })
              end,
              desc = "Format",
              buffer = bufnr,
              silent = true,
              mode = { "n", "v" },
            },
          })

          -- kotlin-lsp 専用：sourcePaths を再インデックス
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "kotlin_lsp" then
            require("which-key").add({
              { "<Leader>ls", group = "Server", buffer = bufnr },
              {
                "<Leader>lsr",
                function()
                  client:exec_cmd({ command = "kotlin-lsp/reindex" })
                end,
                desc = "Reindex (kotlin-lsp)",
                buffer = bufnr,
                silent = true,
              },
              {
                "<Leader>lsc",
                function()
                  client:exec_cmd({ command = "kotlin-lsp/clearCache" })
                end,
                desc = "Clear Cache (kotlin-lsp)",
                buffer = bufnr,
                silent = true,
              },
            })
          end
        end,
      })

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
        "taplo",
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
        ["yaml-language-server"] = "yamlls",
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
              customTags = {
                "!And scalar",
                "!And sequence",
                "!Base64 scalar",
                "!Cidr scalar",
                "!Cidr sequence",
                "!Condition scalar",
                "!Equals sequence",
                "!FindInMap sequence",
                "!GetAZs scalar",
                "!GetAtt scalar",
                "!GetAtt sequence",
                "!If sequence",
                "!ImportValue scalar",
                "!ImportValue mapping",
                "!Join sequence",
                "!Not sequence",
                "!Or sequence",
                "!Ref scalar",
                "!Select sequence",
                "!Split sequence",
                "!Sub scalar",
                "!Sub sequence",
                "!Transform mapping",
              },
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

      -- Hessesian/kotlin-lsp（Rust製、mise の cargo:kotlin-lsp 経由）
      -- 依存ライブラリのソースは `mise run kotlin-lsp:extract-sources` で抽出
      vim.lsp.config("kotlin_lsp", {
        cmd = { "kotlin-lsp" },
        filetypes = { "kotlin" },
        root_markers = {
          "settings.gradle.kts",
          "settings.gradle",
          "build.gradle.kts",
          "build.gradle",
          "pom.xml",
          ".git",
        },
        init_options = {
          indexingOptions = {
            sourcePaths = { vim.fn.expand("~/.local/share/kotlin-lsp/sources") },
          },
        },
      })
      vim.lsp.enable("kotlin_lsp")
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
