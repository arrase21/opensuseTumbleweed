local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Step one ===================================================================
now(function()
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require('mini.icons').setup({
    filetype = {
      go = { glyph = "" }
    },
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })
  later(MiniIcons.mock_nvim_web_devicons)
  later(MiniIcons.tweak_lsp_kind)
end)

now(function() require('mini.notify').setup() end)

now(function() require('mini.sessions').setup() end)

later(function() require('mini.cmdline').setup() end)

later(function() require('mini.comment').setup() end)

later(function() require('mini.cursorword').setup() end)

--Surround ======================================================================================================================
later(function() require('mini.surround').setup({}) end)

now(function()
  require('mini.tabline').setup({
    format = function(buf_id, label)
      local suffix = vim.bo[buf_id].modified and '[+] ' or ''
      return MiniTabline.default_format(buf_id, label) .. suffix
    end,
  })
end)

-- Step one or two ============================================================
now_if_args(function()
  local mini_comp = require('mini.completion')
  mini_comp.setup({
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = function(items, base)
        return mini_comp.default_process_items(items, base, {
          kind_priority = { Text = -1, Snippet = 99 }
        })
      end,
    },
  })
  Config.new_autocmd('LspAttach', nil, function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end, "Set 'omnifunc' for MiniCompletion")
  vim.lsp.config('*', {
    capabilities = mini_comp.get_lsp_capabilities()
  })
end)

now_if_args(function()
  require('mini.files').setup({
    windows = {
      preview = true,
      width_focus = 40,
      width_nofocus = 15,
      width_preview = 85,
    },
    mappings = {
      go_in_plus = "<CR>",
      synchronize = "<Leader>w",
    },
  })

  local add_marks = function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    local vimpack_plugins = vim.fn.stdpath('data') .. '/site/pack/core/opt'
    MiniFiles.set_bookmark('p', vimpack_plugins, { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end
  Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
end)


now_if_args(function()
  require('mini.misc').setup()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
end)


now(function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    window = {
      delay = 100,
      scroll_down = '<C-d>',
      scroll_up = '<C-u>',
    },
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = [[\]] },
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },
      { mode = 'x', keys = '[' },
      { mode = 'x', keys = ']' },
      { mode = 'i', keys = '<C-x>' },
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
    },
  })
end)


later(function()
  require('mini.diff').setup({
    view = {
      style = "sign",
      signs = { add = '󰄛', change = '▒', delete = '消' },
    },
  })
end)

later(function() require('mini.git').setup() end)

later(function()
  require('mini.indentscope').setup({
    symbol = "▏",
    draw = {
      delay = 0, -- sin delay
      animation = require("mini.indentscope").gen_animation.none(),
    },
  })
end)

later(function()
  require('mini.keymap').setup()
  MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
  MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
end)

later(function()
  require('mini.pairs').setup({ modes = { command = true } })
end)


-- Minipick ========================================================================================================================
require('mini.pick').setup({
  mappings = {
    scroll_down  = '',
    scroll_up    = '',
    preview_down = {
      char = '<C-j>',
      func = function()
        local win = require("preview.windows").preview_win
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            vim.cmd("normal! 5\x05")
          end)
        end
      end,
    },

    preview_up   = {
      char = '<C-k>',
      func = function()
        local win = require("preview.windows").preview_win
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            vim.cmd("normal! 5\x19")
          end)
        end
      end,
    },
  },
})

later(function()
  local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    markdown_inline = { 'markdown.json' },
  }
  local snippets = require('mini.snippets')
  local config_path = vim.fn.stdpath('config')
  snippets.setup({
    snippets = {
      snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })
  MiniSnippets.start_lsp_server()
end)

--Starter =======================================================================================================================
Mvim_starter_custom = function()
  return {
    { name = "Quit Neovim", action = "qa", section = "", },
  }
end
require("mini.starter").setup({
  autoopen = true,
  items = {
    Mvim_starter_custom(),
    require("mini.starter").sections.recent_files(3, false, false),
    require("mini.starter").sections.sessions(6, false, false),
    -- require("mini.starter").sections.quit(3, false, false),
  },
  header = function()
    local image = [[
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    █████╗ ██████╗ ██████╗  █████╗ ███████╗███████╗  │
    │   ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝  │
    │   ███████║██████╔╝██████╔╝███████║███████╗█████╗    │
    │   ██╔══██║██╔══██╗██╔══██╗██╔══██║╚════██║██╔══╝    │
    │   ██║  ██║██║  ██║██║  ██║██║  ██║███████║███████╗  │
    │   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝  │
    │                       ARRASE                        │
    └─────────────────────────────────────────────────────┘
    ]]
    return image
  end,
  footer = "",
  query_updater = false,
})
--
-- statusline =======================================================================================================

-- local C = {
--   blue = '#51afef',
--   green = '#98be65',
--   magenta = '#c678dd',
--   yellow = '#ECBE7B',
--   cyan = '#008080',
--   red = '#ec5f67',
--   fg = '#bbc2cf',
-- }
--
-- local MODE_COLORS = {
--   n = C.red,
--   i = C.green,
--   v = C.blue,
--   V = C.blue,
--   ['\22'] = C.blue,
--   c = C.magenta,
--   R = C.magenta,
-- }
-- local function set_hl()
--   for name, opts in pairs({
--     SLMode      = { fg = C.blue, bold = true },
--     SLFile      = { fg = C.magenta, bold = true },
--     SLSysInfo   = { fg = C.green },
--     SLInfo      = { fg = C.fg },
--     Err         = { fg = C.red },
--     Warn        = { fg = C.yellow },
--     Info        = { fg = C.cyan },
--     Hint        = { fg = C.blue },
--     SLGitAdd    = { fg = C.green },
--     SLGitChange = { fg = C.yellow },
--     SLGitDel    = { fg = C.red },
--   }) do
--     vim.api.nvim_set_hl(0, name, vim.tbl_extend('keep', opts, { bg = 'NONE' }))
--   end
-- end
-- set_hl()
-- vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })
--
-- local function lsp_info()
--   local clients = vim.lsp.get_active_clients({ bufnr = 0 })
--   if #clients == 0 then return 'No LSP' end
--   local names = vim.tbl_map(function(c) return c.name end, clients)
--   return table.concat(names, ', ')
-- end
-- local function diag()
--   local counts = vim.diagnostic.count(0)
--   if not next(counts) then return '' end
--   local p = {}
--   if counts[1] then table.insert(p, '%#Err# ' .. counts[1]) end
--   if counts[2] then table.insert(p, '%#Warn# ' .. counts[2]) end
--   if counts[3] then table.insert(p, '%#Info# ' .. counts[3]) end
--   if counts[4] then table.insert(p, '%#Hint#󰌵 ' .. counts[4]) end
--   return table.concat(p, ' ') .. ' '
-- end
--
-- require('mini.statusline').setup({
--   content = {
--     active = function()
--       local git  = MiniStatusline.section_git({ trunc_width = 75, icon = ' ' })
--       local diff = MiniStatusline.section_diff({ trunc_width = 75, icon = '' })
--       local mode = vim.fn.mode()
--       -- local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
--       vim.api.nvim_set_hl(0, 'SLMode', { fg = MODE_COLORS[mode] or C.blue, bg = 'NONE', bold = true })
--       local icons        = require('mini.icons').get('file', vim.fn.expand('%:t'))
--       local enc          = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
--       local icon         = ({ unix = '', dos = '', mac = '' })[vim.bo.fileformat] or ''
--       local d            = diag()
--       local diff_colored = diff:gsub('%+(%d+)', ' %%#SLGitAdd# %1'):gsub('~(%d+)', ' %%#SLGitChange#󰝤 %1'):gsub(
--         '%-(%d+)', ' %%#SLGitDel# %1')
--       local left         = '%#SLMode#▊  '
--           .. ('%#' .. '#' .. icons .. ' ')
--           .. '%#SLFile#%t%m '
--           .. '%#SLInfo# %l:%c  %p%% '
--           .. d
--       local center       = '%#SLLsp# LSP: ' .. lsp_info() .. ' '
--       local right        = '%#SLSysInfo#' .. icon .. ' ' .. string.upper(enc) .. ' '
--           .. (git ~= '' and ('%#SLGitBranch# ' .. git .. ' ' .. diff_colored) or '')
--           .. '%#SLMode#▊'
--       return left .. '%=' .. center .. '%=' .. right
--     end,
--     inactive = function() return '%#SLInfo# %f %=' end,
--   },
-- })


local C = {
  blue     = '#05C3FF',
  green    = '#50FA7B',
  magenta  = '#c678dd',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  red      = '#ec5f67',
  fg       = '#bbc2cf',
  white    = '#ffffff',
  bg_dark  = '#282c34',
  bg_dra   = '#2D2D4E',
  bg_viole = '#9A86FD',
}

local function set_hl()
  for name, opts in pairs({
    SLSepGreen  = { fg = C.green, bg = 'none' },
    SLCapsGreen = { fg = C.bg_dark, bg = C.green, bold = true },
    SLInfo      = { fg = C.green, bg = C.bg_dra, bold = true },
    SLCaps      = { fg = C.bg_dark, bg = C.red, bold = true },
    File        = { fg = C.red, bg = 'none' },
    SLFile      = { fg = 'none', bg = C.bg_dra, bold = true },
    SLLsp       = { fg = C.blue, bg = 'none', bold = true },
    SLMid       = { fg = C.fg, bg = C.bg_viole },
    Err         = { fg = C.red, bg = 'none' },
    Warn        = { fg = C.yellow, bg = 'none' },
    Info        = { fg = C.cyan, bg = 'none' },
    Hint        = { fg = C.blue, bg = 'none' },
    SLGitBranch = { fg = C.fg, bg = 'none', bold = true },
    SLGitAdd    = { fg = C.green, bg = 'none' },
    SLGitChange = { fg = C.yellow, bg = 'none' },
    SLGitDel    = { fg = C.red, bg = 'none' },
  }) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end
set_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })

local function sep(icon, hl_from, hl_to)
  local fg = vim.api.nvim_get_hl(0, { name = hl_from }).bg
  local bg = vim.api.nvim_get_hl(0, { name = hl_to }).bg
  local name = 'SLSep_' .. hl_from .. '_' .. hl_to
  vim.api.nvim_set_hl(0, name, { fg = fg or 'NONE', bg = bg or 'NONE' })
  return '%#' .. name .. '#' .. icon
end

local function lsp_info()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local ignore = { ['mini.snippets'] = true }
  clients = vim.tbl_filter(function(c) return not ignore[c.name] end, clients)
  if #clients == 0 then return 'No LSP' end
  return table.concat(vim.tbl_map(function(c) return c.name end, clients), ', ')
end

local function diag()
  local counts = vim.diagnostic.count(0)
  if not next(counts) then return '' end
  local p = {}
  if counts[1] then table.insert(p, '%#Err#  ' .. counts[1]) end
  if counts[2] then table.insert(p, '%#Warn# ' .. counts[2]) end
  if counts[3] then table.insert(p, '%#Info# ' .. counts[3]) end
  if counts[4] then table.insert(p, '%#Hint#󰌵 ' .. counts[4]) end
  return table.concat(p, ' ') .. '%#SLMid#'
end

require('mini.statusline').setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git           = MiniStatusline.section_git({ trunc_width = 75, icon = ' ' })
      local diff          = MiniStatusline.section_diff({ trunc_width = 75, icon = '' })
      local ficon         = require('mini.icons').get('file', vim.fn.expand('%:t'))
      local vicon         = require('mini.icons').get('filetype', 'vim')
      local user          = os.getenv("USER") or "User"
      local d             = diag()
      local diff_colored  = diff:gsub('%+(%d+)', ' %1'):gsub('~(%d+)', '󰝤 %1'):gsub('%-(%d+)', ' %1')
      -- local icon_fg       = vim.api.nvim_get_hl(0, { name = fhl }).fg
      -- vim.api.nvim_set_hl(0, 'SLFileIcon', { fg = icon_fg, bg = C.bg_dra })
      local left          =
          '%#' .. mode_hl .. '# ' .. vicon .. ' ' .. mode .. ' '
          .. sep('', mode_hl, 'SLMid')
          .. sep('', 'SLMid', 'SLFile')
          .. ' %#SLFile#' .. ficon .. '%#SLFile# %t%m '
          .. sep('', 'SLFile', 'SLNot')
          .. (git ~= '' and ('%#SLGitBranch# ' .. git .. ' ' .. diff_colored) or '')
      local right         =
          d
          .. '%#SLLsp#  LSP:' .. lsp_info() .. ' '
          .. '%#File#'
          .. ''
          .. '%#SLCaps#󰉋 ' .. '%#SLFile# ' .. user .. ' '
          .. '%#SLSepGreen#'
          .. ''
          .. '%#SLCapsGreen#󰈚 ' .. '%#SLInfo# %l:%c '
          .. '%#SLSepGreen#'
      return left .. '%=' .. '%=' .. right
    end,
    inactive = function() return '%#SLInfo# %f %=' end,
  },
})
