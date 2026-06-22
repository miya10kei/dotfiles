local M = {}

local cache = { name = "", branch = "" }

local function git(args)
  local out = vim.fn.system(vim.list_extend({ "git" }, args))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(out)
end

function M.refresh()
  local root = git({ "rev-parse", "--show-toplevel" })
  if not root then
    cache = { name = "", branch = "" }
    return
  end
  cache = {
    name = vim.fn.fnamemodify(root, ":t"),
    branch = git({ "rev-parse", "--abbrev-ref", "HEAD" }) or "",
  }
end

function M.statusline()
  if cache.name == "" then
    return ""
  end
  local branch = cache.branch ~= "" and (cache.branch .. " ") or ""
  return string.format(" ▸ %s %%=%s", cache.name, branch)
end

return M
