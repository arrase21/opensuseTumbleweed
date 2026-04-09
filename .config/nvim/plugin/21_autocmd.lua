vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP: Setup formats, keymaps and completion",
  group = vim.api.nvim_create_augroup("lsp_attach_setup", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local bufnr = event.buf
    local has_mini_completion = _G.MiniCompletion ~= nil
    -- local has_mini_completion = pcall(require, "mini.completion")

    if has_mini_completion then
      vim.bo[bufnr].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    elseif client ~= nil and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    if client and client.server_capabilities.documentFormattingProvider then
      local group = vim.api.nvim_create_augroup("lsp_autoformat_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = bufnr,
        desc = "Format before save",
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            async = false,
            timeout_ms = 1000,
          })
        end,
      })
    end
  end,
})
-- 2. Yank Highlight (Limpio)
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = "Highlight text on yank",
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 150, -- Duración del flash en ms
    })
  end,
})
-- 3. Fix Format Options (Con grupo para evitar leaks)
vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable automatic comment continuation",
  group = vim.api.nvim_create_augroup("FixFormatOptions", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'lua', 'python', 'http', 'json' },
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then return end
    vim.cmd('packadd nvim-treesitter')
    pcall(require('nvim-treesitter.install').install, vim.bo[ev.buf].filetype)
    vim.defer_fn(function() pcall(vim.treesitter.start, ev.buf) end, 500)
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})
