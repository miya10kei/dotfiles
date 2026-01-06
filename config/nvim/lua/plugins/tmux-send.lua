-- tmux-send.lua: Send text to tmux panes
-- <leader>yf - Send current file path to adjacent tmux pane
-- <leader>ys - Send visual selection to tmux pane (visual mode)

local function is_tmux()
  return vim.env.TMUX ~= nil
end

local function get_other_panes()
  if not is_tmux() then
    return {}
  end
  local current_pane = vim.fn.system("tmux display-message -p '#{pane_id}'"):gsub("%s+", "")
  local panes_raw = vim.fn.system("tmux list-panes -F '#{pane_id}:#{pane_index}:#{pane_current_command}'")
  local panes = {}
  for line in panes_raw:gmatch("[^\r\n]+") do
    local pane_id, pane_index, cmd = line:match("([^:]+):([^:]+):(.+)")
    if pane_id and pane_id ~= current_pane then
      table.insert(panes, {
        id = pane_id,
        index = pane_index,
        cmd = cmd,
      })
    end
  end
  return panes
end

local function send_to_pane(pane_id, text)
  local escaped = text:gsub("'", "'\"'\"'")
  vim.fn.system(string.format("tmux send-keys -t %s '%s'", pane_id, escaped))
end

local function select_pane_and_send(panes, text, notify_prefix)
  if #panes == 1 then
    send_to_pane(panes[1].id, text)
    vim.notify(notify_prefix .. " to pane " .. panes[1].index, vim.log.levels.INFO)
    return
  end

  local items = {}
  for _, pane in ipairs(panes) do
    table.insert(items, string.format("%s: %s (%s)", pane.index, pane.cmd, pane.id))
  end

  vim.ui.select(items, {
    prompt = "Select tmux pane:",
  }, function(choice, idx)
    if choice and idx then
      send_to_pane(panes[idx].id, text)
      vim.notify(notify_prefix .. " to pane " .. panes[idx].index, vim.log.levels.INFO)
    end
  end)
end

local function send_file_path()
  if not is_tmux() then
    vim.notify("Not running inside tmux", vim.log.levels.WARN)
    return
  end

  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local panes = get_other_panes()
  if #panes == 0 then
    vim.notify("No other tmux panes found", vim.log.levels.WARN)
    return
  end

  select_pane_and_send(panes, filepath, "Sent file path")
end

local function send_selection()
  if not is_tmux() then
    vim.notify("Not running inside tmux", vim.log.levels.WARN)
    return
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local text = table.concat(lines, "\n")
  local panes = get_other_panes()

  if #panes == 0 then
    vim.notify("No other tmux panes found", vim.log.levels.WARN)
    return
  end

  select_pane_and_send(panes, text, "Sent selection")
end

-- Only setup keymaps when inside tmux
if vim.env.TMUX then
  vim.keymap.set("n", "<leader>yf", send_file_path, { desc = "Send file path to tmux pane" })
  vim.keymap.set("v", "<leader>ys", send_selection, { desc = "Send selection to tmux pane" })
end

-- Return empty table (no external plugins needed)
return {}
