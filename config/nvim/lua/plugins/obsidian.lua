local obsidian_dir = vim.fn.expand("$HOME/dev/ghq/github.com/miya10kei/obsidian")

local function create_knowledge_note()
  local title = vim.fn.input("Title: ")
  if title ~= "" then
    local note = require("obsidian.note").create({
      id = title,
      title = title,
      verbatim = true,
      dir = "20_knowledge",
      tags = { "knowledge" },
    })
    note:write({ template = "knowledge_note.md" })
    vim.cmd.edit(tostring(note.path))
  end
end

-- epwalsh/obsidian.nvim は保守されていないため、コミュニティのフォークを使う
---@type LazySpec
return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "main",
          path = obsidian_dir,
        },
      },
      daily_notes = {
        folder = "10_daily",
        date_format = "%Y-%m-%d",
        default_tags = { "daily" },
        template = "daily_note.md",
      },
      picker = {
        name = "fzf-lua",
      },
      ui = {
        enable = false,
      },
      link = {
        style = "markdown",
      },
      templates = {
        folder = "99_templates",
      },
      frontmatter = {
        func = function(note)
          local title = note.title or note.id
          local out = { title = title, created_at = os.date("%Y-%m-%d %H:%M:%S"), tags = note.tags }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
      },
    },
    keys = {
      { "<LEADER>mg", "<CMD>Obsidian search<CR>", mode = "n", desc = "Search" },
      { "<LEADER>mk", create_knowledge_note, mode = "n", desc = "New knowledge note" },
      { "<LEADER>ms", "<CMD>Obsidian quick_switch<CR>", mode = "n", desc = "Quick switch" },
      { "<LEADER>mo", "<CMD>Obsidian tomorrow<CR>", mode = "n", desc = "Tomorrow" },
      { "<LEADER>mt", "<CMD>Obsidian today<CR>", mode = "n", desc = "Today" },
      { "<LEADER>my", "<CMD>Obsidian yesterday<CR>", mode = "n", desc = "Yesterday" },
    },
  },
}
