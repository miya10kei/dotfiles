---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 100,
    config = function()
      require("mason").setup({
        log_level = vim.log.levels.WARN,
        max_concurrent_installers = 3,
        install = {
          install_timeout = 120000,
        },
      })

      -- 全Masonパッケージを一元定義
      vim.g.mason_packages = {
        -- LSP servers
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
        -- Linters
        "actionlint",
        "hadolint",
        "markdownlint",
        "tfsec",
        -- Formatters
        "prettier",
        "ruff",
        "stylua",
        "yamlfmt",
      }

      vim.api.nvim_create_user_command("MasonInstallNeeded", function()
        local registry = require("mason-registry")
        local packages = vim.g.mason_packages or {}
        local to_install = vim.tbl_filter(function(pkg)
          return not registry.is_installed(pkg)
        end, packages)
        if #to_install > 0 then
          vim.cmd("MasonInstall " .. table.concat(to_install, " "))
        else
          vim.notify("All Mason packages are already installed", vim.log.levels.INFO)
        end
      end, {})
    end,
  },
  { "williamboman/mason-lspconfig.nvim", lazy = false },
}
