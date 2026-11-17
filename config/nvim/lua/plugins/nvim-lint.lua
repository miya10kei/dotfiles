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
        yaml = { "yamllint" },
        -- 複合filetypeは完全一致したキーだけが使われるため、yamllintもここに並べる
        ["yaml.ghaction"] = { "actionlint", "yamllint" },
      }

      -- sqlfluffはdialectの設定がないとエラーになるため、conformと同じ設定ファイルがあるときだけ使う
      local sqlfluff_config_files = { ".sqlfluff", "pep8.ini", "pyproject.toml", "setup.cfg", "tox.ini" }

      local markdownlint_config = vim.fn.expand("~/.markdownlint.jsonc")
      if vim.fn.filereadable(markdownlint_config) == 1 then
        lint.linters["markdownlint-cli2"].args = { "--config", markdownlint_config, "-" }
      end

      local autocmd = require("utils.autocmd")
      autocmd.create_group("lint", {
        {
          event = { "BufEnter", "BufWritePost", "InsertLeave" },
          opts = {
            callback = function(args)
              lint.try_lint()
              -- typosはファイルを直接読むため、ファイルに紐づくバッファだけで走らせる
              -- （ファイル名が空だとカレントディレクトリ全体を走査してしまう）
              if vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= "" then
                lint.try_lint("typos")
              end
              if vim.bo[args.buf].filetype == "sql" and vim.fs.root(args.buf, sqlfluff_config_files) then
                lint.try_lint("sqlfluff")
              end
            end,
          },
        },
      })
    end,
  },
}
