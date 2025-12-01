-- Auto-fold Python docstrings

local function fold_docstrings()
  vim.defer_fn(function()
    local bufnr = vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if vim.bo[bufnr].filetype ~= "python" then
      return
    end

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "python")
    if not ok or not parser then
      return
    end

    local tree = parser:parse()[1]
    if not tree then
      return
    end

    local query_string = [[
      (module . (expression_statement (string) @docstring))
      (class_definition body: (block . (expression_statement (string) @docstring)))
      (function_definition body: (block . (expression_statement (string) @docstring)))
    ]]

    local ok_query, query = pcall(vim.treesitter.query.parse, "python", query_string)
    if not ok_query or not query then
      return
    end

    local save_cursor = vim.api.nvim_win_get_cursor(0)

    for _, node in query:iter_captures(tree:root(), bufnr) do
      local start_row, _, end_row, _ = node:range()
      if end_row > start_row then
        vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
        pcall(vim.cmd, "normal! zc")
      end
    end

    vim.api.nvim_win_set_cursor(0, save_cursor)
  end, 300)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  buffer = 0,
  callback = fold_docstrings,
  desc = "Auto-fold Python docstrings",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  buffer = 0,
  callback = fold_docstrings,
  desc = "Re-fold Python docstrings on window enter",
})
