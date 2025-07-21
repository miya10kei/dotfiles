local options = {
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
  laststatus = 0,
  list = true,
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
