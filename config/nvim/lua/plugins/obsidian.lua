local autocmd = require("utils.autocmd")

local obsidian_dir = vim.fn.expand("$HOME/docs/obsidian")

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

autocmd.create_group("ObsidianAutoSync", {
  {
    event = "BufDelete",
    opts = {
      pattern = obsidian_dir .. "/*",
      callback = function()
        vim.fn.jobstart({
          "bash",
          "-c",
          "cd " .. obsidian_dir .. " && git add -A && git commit -m 'auto: sync' ; git push origin main",
        }, { detach = true })
      end,
    },
  },
})

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
      completion = {
        nvim_cmp = true,
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
        local out = { id = note.id, created_at = os.date("%Y-%m-%d %H:%M:%S"), tags = note.tags }
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
      { "<LEADER>mt", "<CMD>ObsidianToday<CR>", mode = "n", desc = "Today" },
      { "<LEADER>my", "<CMD>ObsidianYesterday<CR>", mode = "n", desc = "Yesterday" },
    },
  },
}
