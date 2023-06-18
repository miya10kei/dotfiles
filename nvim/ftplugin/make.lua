local options = {
    expandtab = false,
    tabstop = 4,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end
