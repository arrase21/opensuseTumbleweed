-- Yank ===
Config.new_autocmd("TextYankPost", "*", function()
  (vim.hl or vim.highlight).on_yank()
end, "Highlight text on yank")

-- Autoformat on save (LSP) ===========================================
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

-- Attach only when LSP client supports formatting =======================
-- ✅ AGREGADO: Desactivar semantic tokens y colorProvider
Config.new_autocmd('LspAttach', '*', function(event)
  local id = vim.tbl_get(event, 'data', 'client_id')
  local client = id and vim.lsp.get_client_by_id(id)
  if not client then return end

  -- 🔥 CRÍTICO: Desactivar features que crean highlights dinámicos
  if client.server_capabilities then
    -- Desactiva semantic tokens (mayor consumidor de highlights)
    client.server_capabilities.semanticTokensProvider = nil
    -- Desactiva color previews en CSS/HTML
    client.server_capabilities.colorProvider = nil
  end

  -- Autoformat si es soportado
  if client:supports_method('textDocument/formatting') then
    Config.lsp_autoformat.buffer_setup(event.buf)
  end
end, 'Enable autoformat on save for buffers with LSP formatting support')

-- Return to last cursor position when reopening a file =====================
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

-- ===================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.isdirectory(arg) == 1 then
      vim.defer_fn(function()
        if MiniFiles then
          MiniFiles.open()
        end
      end, 10) -- Espera 10ms para que los plugins carguen
    end
  end,
})
