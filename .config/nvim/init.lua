-- ┌────────────────┐
-- │ LSP Auto-Enable│
-- └────────────────┘
local lsp_files = vim.api.nvim_get_runtime_file('lsp/*.lua', true)
local configs = {}
for _, path in ipairs(lsp_files) do
  table.insert(configs, vim.fn.fnamemodify(path, ':t:r'))
end
if #configs > 0 then
  vim.lsp.enable(configs)
end

_G.Config = {}

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

local misc            = require('mini.misc')
Config.now            = function(f) misc.safely('now', f) end
Config.later          = function(f) misc.safely('later', f) end
Config.now_if_args    = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event       = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype    = function(ft, f) misc.safely('filetype:' .. ft, f) end

local gr              = vim.api.nvim_create_augroup('custom-config', { clear = true })
Config.new_autocmd    = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, {
    group = gr,
    pattern = pattern,
    callback = callback,
    desc = desc
  })
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  Config.new_autocmd('PackChanged', '*', function(ev)
    local data = ev.data
    if data.spec.name == plugin_name and vim.tbl_contains(kinds, data.kind) then
      if not data.active then vim.cmd.packadd(plugin_name) end
      callback()
    end
  end, desc)
end

require("preview.events").setup()
