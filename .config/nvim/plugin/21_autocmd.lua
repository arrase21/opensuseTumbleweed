-- ==================== LSP COMPLETE CONFIG ================================

-- Autoformat on save (LSP) ===============================================
Config.lsp_autoformat = {}
Config.lsp_autoformat.buffer_setup = function(bufnr)
  local group = 'lsp_autoformat'
  vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = bufnr,
    group = group,
    desc = 'LSP format on save',
    callback = function()
      vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end,
  })
end

-- ✅ ÚNICO LspAttach: maneja TODO =========================================
Config.new_autocmd('LspAttach', '*', function(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then return end

  local bufnr = event.buf

  -- 🔥 Desactivar features problemáticos
  if client.server_capabilities then
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.colorProvider = nil
  end

  -- Autoformat si soporta formatting
  if client.server_capabilities.documentFormattingProvider then
    Config.lsp_autoformat.buffer_setup(bufnr)
  end

  -- 🔥 Document highlight (LazyVim style)
  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.document_highlight,
      desc = 'LSP document highlight',
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.clear_references,
      desc = 'Clear LSP references',
    })
  end

  -- Aquí puedes agregar más handlers (keymaps, etc.)
end, 'LSP: autoformat + document highlight + semanticTokens off')

-- ==================== TUS OTRAS CONFIGS (sin cambios) ====================

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

vim.api.nvim_create_autocmd("filetype", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end
})
