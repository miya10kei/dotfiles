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
        {
          event = { "BufEnter", "BufWritePost", "InsertLeave" },
          opts = {
            pattern = { "*.yaml", "*.yml" },
            callback = function()
              if vim.fn.expand("%:p"):match("/.github/workflows/") then
                lint.try_lint({ "actionlint" })
              end
            end,
          },
        },
      })
    end,
  },
}
