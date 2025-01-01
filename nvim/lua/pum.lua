local M = require("my_module")
local mode = { silent = false, expr = true, noremap = true }

M.keymap("i", "<TAB>", function()
  if vim.fn["pum#visible"]() then
    return vim.fn["pum#map#select_relative"](1)
  else
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col(".")
    if col <= 1 or line:sub(col - 2):match("%s") then
      return "<C-t>"
    else
      return vim.fn["ddc#map#manual_complete"]()
    end
  end
end, mode)

M.keymap("i", "<S-TAB>", function()
  if vim.fn["pum#visible"]() then
    return vim.fn["pum#map#select_relative"](-1)
  else
    return "<C-h>"
  end
end, mode)

M.keymap("i", "<CR>", function()
  if vim.fn["pum#visible"]() then
    return vim.fn["pum#map#confirm"]()
  else
    return "<CR>"
  end
end, mode)

vim.fn["pum#set_option"]({
  border = "none",
  max_height = 10,
  scrollbar_char = "",
  preview = true,
  preview_delay = 0,
})
