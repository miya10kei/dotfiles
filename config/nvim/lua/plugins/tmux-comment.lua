-- Send comments from current line to tmux pane
local M = {}

--- Get comment text from the current line using treesitter
---@return string|nil comment text without comment markers
local function get_comment_from_line()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  -- Try to get comment using treesitter
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if ok and parser then
    local tree = parser:parse()[1]
    if tree then
      local root = tree:root()
      -- Find comment node at current line
      for node in root:iter_children() do
        local start_row, _, end_row, _ = node:range()
        if start_row <= row and row <= end_row then
          if node:type():match("comment") then
            local text = vim.treesitter.get_node_text(node, 0)
            -- Remove common comment prefixes
            text = text:gsub("^%s*//+%s*", "")
            text = text:gsub("^%s*#+%s*", "")
            text = text:gsub("^%s*%-%-+%s*", "")
            text = text:gsub("^%s*/%*+%s*", ""):gsub("%s*%*+/$", "")
            text = text:gsub("^%s*<!%-%-%s*", ""):gsub("%s*%-%->$", "")
            return vim.trim(text)
          end
        end
      end

      -- Try to find comment at cursor position more precisely
      local node = vim.treesitter.get_node({ pos = { row, 0 } })
      while node do
        if node:type():match("comment") then
          local text = vim.treesitter.get_node_text(node, 0)
          text = text:gsub("^%s*//+%s*", "")
          text = text:gsub("^%s*#+%s*", "")
          text = text:gsub("^%s*%-%-+%s*", "")
          text = text:gsub("^%s*/%*+%s*", ""):gsub("%s*%*+/$", "")
          text = text:gsub("^%s*<!%-%-%s*", ""):gsub("%s*%-%->$", "")
          return vim.trim(text)
        end
        node = node:parent()
      end
    end
  end

  -- Fallback: use commentstring to detect comment
  local cs = vim.bo.commentstring
  if cs and cs ~= "" then
    local prefix = cs:gsub("%%s.*", ""):gsub("%s+$", "")
    local suffix = cs:gsub(".*%%s", ""):gsub("^%s+", "")

    if prefix ~= "" then
      local pattern = "^%s*" .. vim.pesc(prefix) .. "%s*(.*)$"
      local match = line:match(pattern)
      if match then
        if suffix ~= "" then
          match = match:gsub(vim.pesc(suffix) .. "%s*$", "")
        end
        return vim.trim(match)
      end
    end
  end

  -- Last resort: try common comment patterns
  local patterns = {
    "^%s*//+%s*(.*)$",
    "^%s*#+%s*(.*)$",
    "^%s*%-%-+%s*(.*)$",
    "^%s*/%*+%s*(.-)%s*%*+/$",
  }
  for _, pattern in ipairs(patterns) do
    local match = line:match(pattern)
    if match then
      return vim.trim(match)
    end
  end

  return nil
end

--- Get list of available tmux panes
---@return table[] list of panes with id and display name
local function get_tmux_panes()
  local handle = io.popen(
    'tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}" 2>/dev/null'
  )
  if not handle then
    return {}
  end

  local result = handle:read("*a")
  handle:close()

  local panes = {}
  for line in result:gmatch("[^\n]+") do
    local id, window_name, command, path = line:match("([^|]+)|([^|]*)|([^|]*)|([^|]*)")
    if id then
      -- Shorten path
      local short_path = path:gsub(os.getenv("HOME") or "", "~")
      table.insert(panes, {
        id = id,
        display = string.format("%s [%s] %s (%s)", id, window_name, command, short_path),
      })
    end
  end
  return panes
end

--- Send text to a tmux pane
---@param pane_id string tmux pane identifier
---@param text string text to send
local function send_to_tmux(pane_id, text)
  -- Escape special characters for tmux
  local escaped = text:gsub("'", "'\\''")
  local cmd = string.format("tmux send-keys -t '%s' '%s'", pane_id, escaped)
  os.execute(cmd)
end

--- Select tmux pane and send comment
function M.send_comment_to_pane()
  local comment = get_comment_from_line()
  if not comment or comment == "" then
    vim.notify("No comment found on current line", vim.log.levels.WARN)
    return
  end

  local panes = get_tmux_panes()
  if #panes == 0 then
    vim.notify("No tmux panes found", vim.log.levels.ERROR)
    return
  end

  -- Use fzf-lua for pane selection
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    local items = {}
    local pane_map = {}
    for _, pane in ipairs(panes) do
      table.insert(items, pane.display)
      pane_map[pane.display] = pane.id
    end

    fzf.fzf_exec(items, {
      prompt = "Select tmux pane> ",
      actions = {
        ["default"] = function(selected)
          if selected and #selected > 0 then
            local pane_id = pane_map[selected[1]]
            if pane_id then
              send_to_tmux(pane_id, comment)
              vim.notify(string.format("Sent to %s: %s", pane_id, comment), vim.log.levels.INFO)
            end
          end
        end,
      },
    })
  else
    -- Fallback to vim.ui.select
    local items = {}
    for _, pane in ipairs(panes) do
      table.insert(items, pane)
    end

    vim.ui.select(items, {
      prompt = "Select tmux pane:",
      format_item = function(item)
        return item.display
      end,
    }, function(choice)
      if choice then
        send_to_tmux(choice.id, comment)
        vim.notify(string.format("Sent to %s: %s", choice.id, comment), vim.log.levels.INFO)
      end
    end)
  end
end

---@type LazySpec
return {
  dir = vim.fn.stdpath("config"),
  name = "tmux-comment",
  lazy = false,
  config = function()
    vim.keymap.set("n", "<leader>tc", M.send_comment_to_pane, {
      silent = true,
      noremap = true,
      desc = "Send comment to tmux pane",
    })
  end,
}
