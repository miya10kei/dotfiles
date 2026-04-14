---@type LazySpec
return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    enabled = false,
    build = "npm install -g mcp-hub@latest",
    opts = {
      extensions = {
        avante = {
          make_slash_commands = true,
        },
      },
    },
  },
}
