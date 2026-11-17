vim.g.mapleader = " "

-- herdr は OSC52 read の応答をpaneへ返送しないため、herdr内ではpasteが永久に待機する
local function herdr_paste_fallback()
  return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
end

local osc52 = require("vim.ui.clipboard.osc52")
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

local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.cmdheight = 2
opt.expandtab = true
opt.fileformats = "unix,mac,dos"
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.ignorecase = true
opt.laststatus = 3
opt.list = true
opt.listchars = {
  tab = "»-",
  trail = "-",
  eol = "↲",
  extends = "»",
  precedes = "«",
  nbsp = "%",
}
opt.number = true
opt.shiftwidth = 4
opt.showtabline = 2
opt.smartcase = true
opt.statusline = "%!v:lua.require'utils.worktree'.statusline()"
opt.swapfile = false
opt.tabstop = 4
opt.updatetime = 250
opt.virtualedit = "onemore"

-- GitHub Actionsのワークフローはactionlintとyamllsで扱えるよう専用のfiletypeにする
vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
  },
})

vim.api.nvim_create_user_command("Jq", "%!jq '.'", { desc = "Format the buffer as JSON with jq" })
