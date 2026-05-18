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
            { "gi", fzf("lsp_implementations"), desc = "Implementation", buffer = bufnr, silent = true },
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
              -- kotlin-lsp は型推論を持たず textDocument/implementation が空になりがち。
              -- 空のときだけ ripgrep で `override fun <cword>` を引いて補う。
              -- 件数による分岐: 1 件→直接ジャンプ（picker 不表示）/ 2+ 件→fzf-lua picker。
              {
                "gi",
                function()
                  -- async callback 中にカーソルが動いている可能性があるので cword は先に確保
                  local word = vim.fn.expand("<cword>")
                  local enc = client.offset_encoding or "utf-16"
                  local params = vim.lsp.util.make_position_params(0, enc)

                  local function jump_to(filename, lnum, col)
                    vim.cmd.edit(filename)
                    vim.api.nvim_win_set_cursor(0, { lnum, math.max(0, col - 1) })
                  end

                  vim.lsp.buf_request_all(0, "textDocument/implementation", params, function(results)
                    local items = {}
                    for _, res in pairs(results or {}) do
                      if res.err then
                        vim.notify(
                          ("kotlin-lsp implementation error: %s"):format(res.err.message or vim.inspect(res.err)),
                          vim.log.levels.WARN
                        )
                      end
                      if res.result and not vim.tbl_isempty(res.result) then
                        local locs = vim.islist(res.result) and res.result or { res.result }
                        vim.list_extend(items, vim.lsp.util.locations_to_items(locs, enc))
                      end
                    end

                    if #items == 1 then
                      jump_to(items[1].filename, items[1].lnum, items[1].col)
                      return
                    end
                    if #items > 1 then
                      vim.fn.setqflist({}, " ", { title = "kotlin-lsp implementations", items = items })
                      require("fzf-lua").quickfix()
                      return
                    end

                    -- LSP 0 件 → rg fallback
                    if not word:match("^[%w_]+$") then
                      vim.notify("kotlin gi: cursor is not on an identifier", vim.log.levels.INFO)
                      return
                    end
                    local pattern = "override fun " .. word .. "\\b"
                    local rg_lines = vim.fn.systemlist({ "rg", "--vimgrep", "--no-heading", pattern })
                    if #rg_lines == 0 then
                      vim.notify("kotlin gi: no implementations found", vim.log.levels.INFO)
                      return
                    end
                    if #rg_lines == 1 then
                      local file, lnum, col = rg_lines[1]:match("^(.-):(%d+):(%d+):")
                      if file then
                        jump_to(file, tonumber(lnum), tonumber(col))
                        return
                      end
                    end
                    require("fzf-lua").grep({
                      search = pattern,
                      no_esc = true,
                      prompt = "Kotlin impls (rg)> ",
                    })
                  end)
                end,
                desc = "Implementation (LSP → rg fallback)",
                buffer = bufnr,
                silent = true,
              },
            })
          end
        end,
      })

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

      local servers = {
        "angularls",
        "bashls",
        "docker_compose_language_service",
        "docker_language_server",
        "gopls",
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
        -- kotlin-lsp（Rust製、mise の cargo:kotlin-lsp 経由）
        -- 依存ライブラリのソースは `mise run kotlin-lsp:extract-sources` で抽出
        kotlin_lsp = {
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
        },
        -- typescript-language-server は同居する `typescript` を必要とするが、
        -- mise では別 prefix にインストールされるため tsserver の所在を明示する
        ts_ls = (function()
          local mise_root = vim.fn.trim(vim.fn.system("mise where npm:typescript"))
          if vim.v.shell_error ~= 0 or mise_root == "" then
            vim.notify("mise where npm:typescript failed; ts_ls may not find tsserver", vim.log.levels.WARN)
            return {}
          end
          return {
            init_options = {
              tsserver = { path = mise_root .. "/lib/node_modules/typescript/lib" },
            },
          }
        end)(),
      }

      -- LSPサーバーの設定と有効化
      for _, name in ipairs(servers) do
        if lsp_settings[name] then
          vim.lsp.config(name, lsp_settings[name])
        end
        local ok, err = pcall(vim.lsp.enable, name)
        if not ok then
          vim.notify(string.format("Failed to enable LSP %s: %s", name, err), vim.log.levels.WARN)
        end
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
