---@type LazySpec
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Masonパッケージを登録
      vim.g.mason_packages = vim.g.mason_packages or {}
      vim.list_extend(vim.g.mason_packages, {
        "actionlint",
        "hadolint",
        "markdownlint-cli",
        "ruff",
        "tfsec",
      })

      local lint = require("lint")
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        terraform = { "tfsec" },
        tf = { "tfsec" },
        ["yaml.ghaction"] = { "actionlint" },
      }

      local autocmd = require("utils.autocmd")
      autocmd.create_group("lint", {
        {
          event = { "BufEnter", "BufWritePost", "InsertLeave" },
          opts = {
            callback = function()
              lint.try_lint()
            end,
          },
        },
      })
    end,
  },
}
