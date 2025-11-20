-- Yank ===
Config.new_autocmd("TextYankPost", "*", function()
  (vim.hl or vim.highlight).on_yank()
end, "Highlight text on yank")


-- Autoformat on save (LSP)
Config.lsp_autoformat = {}

-- Define helper for setting up buffer-specific autocmd
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

-- Attach only when LSP client supports formatting
Config.new_autocmd('LspAttach', '*', function(event)
  local id = vim.tbl_get(event, 'data', 'client_id')
  local client = id and vim.lsp.get_client_by_id(id)
  if not client then return end

  if client:supports_method('textDocument/formatting') then
    Config.lsp_autoformat.buffer_setup(event.buf)
  end
end, 'Enable autoformat on save for buffers with LSP formatting support')
