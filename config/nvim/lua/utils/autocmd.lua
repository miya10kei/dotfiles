local M = {}

function M.create_group(name, autocmds)
  local group = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd.event, vim.tbl_extend("force", autocmd.opts, { group = group }))
  end
end

return M
