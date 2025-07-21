local function create_autocmd_group(name, autocmds)
  local group = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd.event, vim.tbl_extend("force", autocmd.opts, { group = group }))
  end
end

-- LSP formatting on save
create_autocmd_group("FileTypeIndent", {
  {
    event = "BufWritePre",
    opts = {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          filter = function(lsp_client)
            return lsp_client.name == "null-ls"
          end,
        })
      end,
    },
  },
})

-- Restore cursor position
create_autocmd_group("Extends", {
  {
    event = "BufRead",
    opts = {
      pattern = "*",
      callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
          vim.api.nvim_command('normal g`"')
        end
      end,
    },
  },
})

-- Oil.nvim relative path fix
create_autocmd_group("OilRelPathFix", {
  {
    event = "BufLeave",
    opts = {
      pattern = "oil:///*",
      callback = function()
        vim.cmd("cd .")
      end,
    },
  },
})
