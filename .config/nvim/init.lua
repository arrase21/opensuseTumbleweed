-- ┌────────────────┐
-- │ Plugin manager │
-- └────────────────┘
local configs = vim.tbl_map(function(path)
  return vim.fn.fnamemodify(path, ':t:r')
end, vim.api.nvim_get_runtime_file('lsp/*.lua', true))

vim.lsp.enable(configs)

_G.Config = {}

-- Load now to have 'mini.misc' available for custom loading helpers.
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end

local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback()
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end
require("preview.events").setup()

-- local function source_matugen()
--   local matugen_path = os.getenv("HOME") .. "/.config/nvim/colors/generated.lua"
--
--   if vim.fn.filereadable(matugen_path) == 1 then
--     dofile(matugen_path)
--   else
--     vim.cmd("colorscheme base16-catppuccin-mocha")
--     vim.notify("Matugen aún no generó colores", vim.log.levels.INFO)
--   end
-- end
--
-- vim.api.nvim_create_autocmd("Signal", {
--   pattern = "SIGUSR1",
--   callback = function()
--     source_matugen()
--
--     vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
--     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
--     vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })
--     vim.api.nvim_set_hl(0, "Comment", { italic = true })
--   end,
-- })
-- Config.later(function()
--   source_matugen()
-- end)
