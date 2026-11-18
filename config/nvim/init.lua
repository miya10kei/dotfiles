-- lazy.nvimより前に読み込む（mapleaderはプラグインのキーマップ定義より先に設定する必要がある）
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
