local obsidian_dir = vim.fn.expand("$HOME/dev/ghq/github.com/miya10kei/obsidian")

local function create_knowledge_note()
  local title = vim.fn.input("Title: ")
  if title ~= "" then
    local client = require("obsidian").get_client()
    local note = client:create_note({ id = title, title = title, dir = "20_knowledge" })
    note:add_tag("knowledge")
    vim.cmd("edit " .. tostring(note.path))
    client:write_note_to_buffer(note, { template = "knowledge_note.md" })
  end
end

---@type LazySpec
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
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
      mappings = {},
      ui = {
        enable = false,
      },
      preferred_link_style = "markdown",
      templates = {
        folder = "99_templates",
      },
      note_frontmatter_func = function(note)
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
    keys = {
      { "<LEADER>mg", "<CMD>ObsidianSearch<CR>", mode = "n", desc = "Search" },
      { "<LEADER>mk", create_knowledge_note, mode = "n", desc = "New knowledge note" },
      { "<LEADER>ms", "<CMD>ObsidianQuickSwitch<CR>", mode = "n", desc = "Quick switch" },
      { "<LEADER>mo", "<CMD>ObsidianTomorrow<CR>", mode = "n", desc = "Tomorrow" },
      { "<LEADER>mt", "<CMD>ObsidianToday<CR>", mode = "n", desc = "Today" },
      { "<LEADER>my", "<CMD>ObsidianYesterday<CR>", mode = "n", desc = "Yesterday" },
    },
  },
}
