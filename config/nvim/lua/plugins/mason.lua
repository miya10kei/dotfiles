---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 100,
    config = function()
      require("mason").setup({
        log_level = vim.log.levels.WARN,
        max_concurrent_installers = 1,
        install = {
          install_timeout = 60000,
        },
      })

      vim.api.nvim_create_user_command("MasonInstallNeeded", function()
        local registry = require("mason-registry")
        local packages = vim.g.mason_packages or {}
        local to_install = vim.tbl_filter(function(pkg)
          return not registry.is_installed(pkg)
        end, packages)
        if #to_install > 0 then
          vim.cmd("MasonInstall " .. table.concat(to_install, " "))
        else
          vim.notify("All Mason packages are already installed", vim.log.levels.INFO)
        end
      end, {})
    end,
  },
  { "williamboman/mason-lspconfig.nvim", lazy = false },
}
