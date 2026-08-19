local osc52 = require("vim.ui.clipboard.osc52")

-- herdr は OSC52 read の応答をpaneへ返送しないため、herdr内ではpasteが永久に待機する
local function herdr_paste_fallback()
  return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
end

local in_herdr = vim.env.HERDR_ENV == "1"

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = in_herdr and herdr_paste_fallback or osc52.paste("+"),
    ["*"] = in_herdr and herdr_paste_fallback or osc52.paste("*"),
  },
}

local options = {
  autoread = true,
  background = "dark",
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 2,
  encoding = "utf-8",
  expandtab = true,
  fileencoding = "utf-8",
  fileformats = "unix,mac,dos",
  foldcolumn = "1",
  foldlevel = 99,
  foldlevelstart = 99,
  foldenable = true,
  ignorecase = true,
  laststatus = 3,
  list = true,
  statusline = "%!v:lua.require'utils.worktree'.statusline()",
  number = true,
  listchars = {
    tab = "»-",
    trail = "-",
    eol = "↲",
    extends = "»",
    precedes = "«",
    nbsp = "%",
  },
  shiftwidth = 4,
  showtabline = 2,
  smartcase = true,
  swapfile = false,
  tabstop = 4,
  termguicolors = true,
  updatetime = 250,
  virtualedit = "onemore",
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
