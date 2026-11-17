-- typescript-language-server は同居する `typescript` を必要とするが、
-- mise では別 prefix にインストールされるため tsserver の所在を明示する
local mise_root = vim.fn.executable("mise") == 1 and vim.trim(vim.fn.system({ "mise", "where", "npm:typescript" }))
  or ""
if vim.v.shell_error ~= 0 or mise_root == "" then
  vim.notify("mise where npm:typescript failed; ts_ls may not find tsserver", vim.log.levels.WARN)
  return {}
end

---@type vim.lsp.Config
return {
  init_options = {
    tsserver = { path = mise_root .. "/lib/node_modules/typescript/lib" },
  },
}
