---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
    event = "InsertEnter",
  },
}
