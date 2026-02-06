vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP autoformat",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    -- Solo si soporta formatting
    if not client.server_capabilities.documentFormattingProvider then
      return
    end

    local bufnr = event.buf
    local group = vim.api.nvim_create_augroup("lsp_autoformat", { clear = false })

    -- Evita duplicados
    vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      buffer = bufnr,
      desc = "Format before save",
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          async = false,
          timeout_ms = 10000,
        })
      end,
    })
  end,
})

-- Yank ===
Config.new_autocmd("TextYankPost", "*", function()
  (vim.hl or vim.highlight).on_yank()
end, "Highlight text on yank")

Config.checktime = {}
Config.checktime = function()
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
      if vim.o.buftype ~= "nofile" then
        vim.cmd("checktime")
      end
    end,
  })
end

-- Return to last cursor position when reopening a file ===================
Config.new_autocmd("BufReadPost", "*", function(event)
  local exclude = { "gitcommit" }
  local buf = event.buf
  if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].vim_last_loc then
    return
  end
  vim.b[buf].vim_last_loc = true
  local mark = vim.api.nvim_buf_get_mark(buf, '"')
  local lcount = vim.api.nvim_buf_line_count(buf)
  if mark[1] > 0 and mark[1] <= lcount then
    pcall(vim.api.nvim_win_set_cursor, 0, mark)
  end
end, "Restore last cursor position")

-- VimEnter para MiniFiles ================================================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.isdirectory(arg) == 1 then
      vim.defer_fn(function()
        if MiniFiles then
          MiniFiles.open()
        end
      end, 10)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end
})


vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'lua', 'python', 'http' },
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.treesitter.start()
    end
  end,
})
