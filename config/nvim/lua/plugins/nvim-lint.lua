---@type LazySpec
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        markdown = { "markdownlint-cli2" },
        python = { "ruff" },
        terraform = { "trivy" },
        tf = { "trivy" },
        ["yaml.ghaction"] = { "actionlint" },
      }

      local markdownlint_config = vim.fn.expand("~/.markdownlint.jsonc")
      if vim.fn.filereadable(markdownlint_config) == 1 then
        lint.linters["markdownlint-cli2"].args = { "--config", markdownlint_config, "-" }
      end

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
