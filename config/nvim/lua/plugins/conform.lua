---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<LEADER>f",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
      {
        "<LEADER>t",
        function()
          if vim.g.conform_format_on_save then
            vim.g.conform_format_on_save = false
            vim.notify("Format on save disabled", vim.log.levels.INFO)
          else
            vim.g.conform_format_on_save = true
            vim.notify("Format on save enabled", vim.log.levels.INFO)
          end
        end,
        desc = "Toggle format on save",
      },
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        html = { "prettier" },
        graphql = { "prettier" },
        handlebars = { "prettier" },
        lua = { "stylua" },
        markdown = { "markdownlint" },
        python = { "isort", "black" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        yaml = { "yamlfmt" },
        ["_"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function()
        if vim.g.conform_format_on_save == false then
          return nil
        end
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end,
      formatters = {
        black = {
          prepend_args = { "--line-length", "120" },
        },
      },
      notify_on_error = true,
      notify_no_formatters = false,
    },
    init = function()
      vim.g.conform_format_on_save = true
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
