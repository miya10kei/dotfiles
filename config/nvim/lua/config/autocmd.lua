local autocmd = require("utils.autocmd")

-- Restore cursor position
autocmd.create_group("Extends", {
  {
    event = "BufRead",
    opts = {
      pattern = "*",
      callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
          vim.cmd('normal g`"')
        end
      end,
    },
  },
})

-- Oil.nvim relative path fix
autocmd.create_group("OilRelPathFix", {
  {
    event = "BufLeave",
    opts = {
      pattern = "oil:///*",
      callback = function()
        vim.cmd("cd .")
      end,
    },
  },
})

-- fzf-specific keymaps
autocmd.create_group("FzfKeymaps", {
  {
    event = "FileType",
    opts = {
      pattern = "fzf",
      callback = function()
        vim.keymap.set("t", "<C-j>", "<Down>", { buffer = true, silent = true })
        vim.keymap.set("t", "<C-k>", "<Up>", { buffer = true, silent = true })
      end,
    },
  },
})

-- Terminal auto insert mode
autocmd.create_group("TerminalConfig", {
  {
    event = "TermOpen",
    opts = {
      pattern = "*",
      command = "startinsert",
    },
  },
})

-- GitHub Actions workflow files
autocmd.create_group("GitHubActionsFiletype", {
  {
    event = { "BufRead", "BufNewFile" },
    opts = {
      pattern = { "*/.github/workflows/*.yaml", "*/.github/workflows/*.yml" },
      callback = function()
        vim.bo.filetype = "yaml.ghaction"
      end,
    },
  },
})
