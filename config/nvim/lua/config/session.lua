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
      vim.notify("Session restored!", vim.log.levels.INFO)

      -- Delete session file after restoration
      vim.fn.delete(session_file)
    end
  end,
})
