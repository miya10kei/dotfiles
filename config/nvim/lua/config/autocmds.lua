local autocmd = require("utils.autocmd")

-- 前回のカーソル位置を復元する
autocmd.create_group("RestoreCursor", {
  {
    event = "BufReadPost",
    opts = {
      callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    },
  },
})

-- 外部で変更されたファイルを読み直す
autocmd.create_group("Checktime", {
  {
    event = { "BufEnter", "FocusGained", "TermClose", "TermLeave" },
    opts = {
      command = "checktime",
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
      command = "startinsert",
    },
  },
})

-- Worktree名をステータスラインへ反映
autocmd.create_group("WorktreeStatusline", {
  {
    event = { "VimEnter", "DirChanged" },
    opts = {
      callback = function()
        require("utils.worktree").refresh()
      end,
    },
  },
})

-- LSPクライアントの強制停止（kotlin-lsp等のゾンビJVM対策）
autocmd.create_group("LspForceStopOnExit", {
  {
    event = "VimLeavePre",
    opts = {
      callback = function()
        for _, client in ipairs(vim.lsp.get_clients()) do
          client:stop(true)
        end
      end,
    },
  },
})
