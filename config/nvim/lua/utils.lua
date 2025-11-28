local M = {}

---@param key string
---@param mode? string
function M.feedkey(key, mode)
  local keycode = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(keycode, mode or "n", false)
end

return M
