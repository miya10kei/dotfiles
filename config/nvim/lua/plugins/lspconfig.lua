---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    main = "lsp",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls.nvim",
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
        keymap("n", "<SPACE>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        keymap("n", "<SPACE>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        keymap("n", "<SPACE>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        keymap("n", "<SPACE>D", vim.lsp.buf.type_definition, bufopts)
        keymap("n", "<SPACE>rn", vim.lsp.buf.rename, bufopts)
        keymap("n", "<SPACE>ca", vim.lsp.buf.code_action, bufopts)
        keymap("n", "<SPACE>f", function()
          vim.lsp.buf.format({ async = true })
        end, bufopts)
      end

      -------------
      --- Mason ---
      -------------
      require("mason").setup({
        log_level = vim.log.levels.WARN,
        max_concurrent_installers = 1,
        install = {
          install_timeout = 60000,
        },
      })
      require("mason-lspconfig").setup()
      local mason_registry = require("mason-registry")
      local mason_package = require("mason-core.package")

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

      local used_masson_packages = {
        ["lsp"] = {
          "angular-language-server",
          "bash-language-server",
          "docker-compose-language-service",
          "dockerfile-language-server",
          "gopls",
          "haskell-language-server",
          "html-lsp",
          "json-lsp",
          "lua-language-server",
          "marksman",
          "pyright",
          "rust-analyzer",
          --"taplo",
          "terraform-ls",
          "typescript-language-server",
          "yaml-language-server",
        },
        ["linter"] = {
          "actionlint",
          "hadolint",
          "markdownlint",
          "tflint",
          "tfsec",
        },
        ["formatter"] = {
          "black",
          "goimports",
          "isort",
          "markdownlint",
          "prettier",
          "stylua",
          "yamlfmt",
        },
      }

      -- Mason パッケージ名から lspconfig の設定名へのマッピング
      local mason_to_lsp = {
        ["angular-language-server"] = "angularls",
        ["bash-language-server"] = "bashls",
        ["docker-compose-language-service"] = "docker_compose_language_service",
        ["dockerfile-language-server"] = "dockerls",
        ["haskell-language-server"] = "hls",
        ["html-lsp"] = "html",
        ["json-lsp"] = "jsonls",
        ["lua-language-server"] = "lua_ls",
        ["rust-analyzer"] = "rust_analyzer",
        ["terraform-ls"] = "terraformls",
        ["typescript-language-server"] = "ts_ls",
      }

      for _, v in pairs(used_masson_packages["lsp"]) do
        local alias = mason_to_lsp[v] or mason_registry.get_package_aliases(v)[1] or v
        if alias == "lua_ls" then
          vim.lsp.config(alias, {
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = {
                    "vim",
                  },
                },
                workspace = {
                  library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    vim.fn.stdpath("data") .. "/lazy/blink.cmp", -- blink.cmp用に追加
                  },
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        elseif alias == "rust_analyzer" then
          vim.lsp.config(alias, {
            settings = {
              ["rust-analyzer"] = {
                import = {
                  granularity = {
                    group = "module",
                  },
                },
                prefix = "self",
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
            },
          })
        elseif alias == "yamlls" then
          vim.lsp.config(alias, {
            settings = {
              yaml = {
                format = {
                  enable = false,
                },
                schemas = {
                  ["https://json.schemastore.org/github-action.json"] = ".github/actions/*.yaml",
                  ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yaml",
                  ["https://raw.githubusercontent.com/aws/aws-sam-cli/master/schema/samcli.json"] = "samconfig.yaml",
                  ["https://raw.githubusercontent.com/aws/serverless-application-model/develop/samtranslator/validator/sam_schema/schema.json"] = "template*.yaml",
                },
              },
            },
          })
        elseif alias == "bashls" then
          vim.lsp.config(alias, {
            filetypes = { "sh", "bash", "zsh" }, -- .zshファイルも含める
          })
        elseif alias == "copilot-language-server" then
          -- copilot-language-serverは設定・有効化をスキップ
        end
      end

      -- LSPサーバーの有効化
      for _, v in pairs(used_masson_packages["lsp"]) do
        local alias = mason_to_lsp[v] or mason_registry.get_package_aliases(v)[1] or v
        if alias ~= "copilot-language-server" then
          vim.lsp.enable(alias)
        end
      end

      ---------------
      --- null-ls ---
      ---------------
      local null_ls = require("null-ls")
      local null_sources = {
        null_ls.builtins.formatting.terraform_fmt,
      }

      for _, package in ipairs(mason_registry.get_installed_packages()) do
        for _, package_category in ipairs(package.spec.categories) do
          if package_category == mason_package.Cat.Formatter then
            for k, _ in pairs(package.spec.bin) do
              local name = string.gsub(k, "-", "_")
              local source = null_ls.builtins.formatting[name]
              if source then
                if name == "autoflake" then
                  source = source.with({
                    extra_args = {
                      "--remove-rhs-for-unused-variables",
                      "--remove-all-unused-imports",
                      "--remove-duplicate-keys",
                      "--remove-unused-variables",
                    },
                  })
                elseif name == "black" then
                  source = source.with({
                    extra_args = {
                      "--line-length",
                      "120",
                    },
                  })
                elseif name == "prettier" then
                  source = source.with({
                    filetypes = {
                      "javascript",
                      "javascriptreact",
                      "typescript",
                      "typescriptreact",
                      "vue",
                      "css",
                      "scss",
                      "less",
                      "html",
                      "markdown.mdx",
                      "graphql",
                      "handlebars",
                    },
                  })
                end
                table.insert(null_sources, source)
              end
            end
          elseif package_category == mason_package.Cat.Linter then
            for k, _ in pairs(package.spec.bin) do
              local source = null_ls.builtins.diagnostics[k]
              if source and k ~= "tflint" then
                table.insert(null_sources, source)
              end
            end
          end
        end
      end

      null_ls.setup({
        diagnostics_format = "#{m} (#{s}: #{c})",
        sources = null_sources,
        on_attach = function()
          local function toggle_source()
            local query = {
              method = null_ls.methods.FORMATTING,
            }
            null_ls.toggle(query)
            local sources = null_ls.get_source(query)
            if sources[1]._disabled then
              vim.notify("null_ls formatter disabled", vim.log.levels.INFO)
            else
              vim.notify("null_ls formatter enabled", vim.log.levels.INFO)
            end
          end
          keymap("n", "<LEADER>t", toggle_source, {
            silent = true,
          })
        end,
      })

      ---------------------
      --- User Commands ---
      ---------------------
      vim.api.nvim_create_user_command("MasonInstallNeeded", function()
        local install_packages = {}
        for _, packages in pairs(used_masson_packages) do
          local not_installed_packages = {}
          for _, package in pairs(packages) do
            if not mason_registry.is_installed(package) then
              table.insert(not_installed_packages, package)
            end
          end
          local not_installed_packages_string = table.concat(not_installed_packages, " ")
          table.insert(install_packages, not_installed_packages_string)
        end
        local install_packages_string = table.concat(install_packages, " ")
        vim.api.nvim_command(string.format("MasonInstall %s", install_packages_string))
      end, {})
    end,
    keys = {
      {
        "<SPACE>e",
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
        "<SPACE>q",
        vim.diagnostic.setloclist(),
        desc = "Set diagnostic to loclist",
      },
    },
  },
}
