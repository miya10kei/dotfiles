---@type LazySpec
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local autocmd = require("utils.autocmd")
      local lint = require("lint")

      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
        terraform = { "tfsec" },
        tf = { "tfsec" },
        yaml = { "actionlint" },
      }

      -- actionlint only for GitHub Actions files
      lint.linters.actionlint = {
        condition = function(ctx)
          return ctx.filename:match("%.github/workflows/")
        end,
      }

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
