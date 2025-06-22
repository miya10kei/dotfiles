local options = {
  expandtab = true,
  tabstop = 4,
  shiftwidth = 4,
}

for k, v in pairs(options) do
  vim.bo[k] = v
end
