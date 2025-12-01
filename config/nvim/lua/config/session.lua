-- Session management configuration

-- Configure what to save in sessions
vim.opt.sessionoptions = {
  "blank", -- empty windows
  "buffers", -- hidden and unloaded buffers
  "curdir", -- current directory
  "folds", -- folds
  "help", -- help windows
  "tabpages", -- tab pages
  "winsize", -- window sizes
  "winpos", -- window positions
  "terminal", -- terminal windows
}

local session_file = vim.fn.stdpath("data") .. "/last-session.vim"

-- F5: Save session and restart
vim.keymap.set("n", "<F5>", function()
  local ok, err = pcall(function()
    vim.cmd("mksession! " .. session_file)
  end)

  if ok then
    vim.notify("Session saved! Restarting...", vim.log.levels.INFO)

    -- Check if running in tmux
    local tmux_pane = vim.env.TMUX_PANE
    if tmux_pane then
      -- Use tmux respawn-pane to restart nvim automatically
      vim.fn.system("tmux respawn-pane -k -t " .. tmux_pane .. " nvim")
    else
      -- Fallback: just quit if not in tmux
      vim.notify("Not in tmux. Please restart nvim manually.", vim.log.levels.WARN)
      vim.cmd("qa")
    end
  else
    vim.notify("Failed to save session: " .. err, vim.log.levels.ERROR)
  end
end, { silent = true, noremap = true, desc = "Save session and restart" })

-- Auto-restore session on startup (if exists and no arguments)
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    -- Only restore if:
    -- 1. No files were specified as arguments
    -- 2. Session file exists
    if vim.fn.argc() == 0 and vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
      vim.cmd("stopinsert")
      vim.fn.delete(session_file)

      -- Re-edit all buffers to trigger FileType/TreeSitter initialization
      vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "" and vim.fn.bufname(buf) ~= "" then
            vim.api.nvim_win_call(win, function()
              local cursor = vim.api.nvim_win_get_cursor(0)
              vim.cmd("silent! edit")
              pcall(vim.api.nvim_win_set_cursor, 0, cursor)
            end)
          end
        end
        vim.notify("Session restored!", vim.log.levels.INFO)
      end, 50)
    end
  end,
})
