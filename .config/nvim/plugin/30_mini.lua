-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘

_G.Config = _G.Config or {}

-- require('mini.basics').setup({
--   -- Manage options in 'plugin/10_options.lua' for didactic purposes
--   options = { basic = false },
--   mappings = {
--     -- Create `<C-hjkl>` mappings for window navigation
--     windows = true,
--     -- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
--     move_with_alt = true,
--   },
-- })

-- Mini Icons ======================================================================
do
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }

  require('mini.icons').setup({
    use_file_extension = function(ext)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })

  MiniIcons.mock_nvim_web_devicons()
  MiniIcons.tweak_lsp_kind()
end
-- Misc =====================================
-- Makes `:h MiniMisc.put()` and `:h MiniMisc.put_text()` public
require('mini.misc').setup()
MiniMisc.setup_auto_root()
MiniMisc.setup_termbg_sync()

-- Mini Sessions =====================================================================
do
  require('mini.sessions').setup({
    autowrite = true,
    directory = vim.fn.stdpath('data') .. '/sessions',
  })

  _G.save_project_session = function()
    local name = vim.fn.getcwd():gsub('[:\\/]', '_')
    MiniSessions.write(name)
    print("Proyecto guardado: " .. name)
  end

  vim.keymap.set('n', '<leader>sp',
    function() _G.save_project_session() end,
    { desc = 'Guardar Proyecto' }
  )
end

-- Mini Notify ==============================================================================

require('mini.notify').setup({})

-- Mini Tabline ==============================================================================
require('mini.tabline').setup()

-- Mini Extra ==============================================================================
require('mini.extra').setup()

-- Mini Comment ===========================================================================
require('mini.comment').setup()



-- local starter = require("mini.starter")
--
-- starter.setup({
--   header = table.concat({
--     "",
--     "",
--     "          Hello World!",
--     "",
--   }, "\n"),
--
--   items = {
--     {
--       name = "Create Note",
--       action = function()
--         vim.cmd("ene")
--         vim.cmd("startinsert")
--       end,
--       section = "",
--     },
--
--     {
--       name = "Open file",
--       action = function()
--         require("mini.pick").builtin.files()
--       end,
--       section = "",
--     },
--
--
--     {
--       name = "Recent Files",
--       action = function()
--         require("mini.pick").start({
--           source = {
--             name = "Recent files",
--             items = vim.v.oldfiles,
--             choose = function(path)
--               vim.cmd("edit " .. path)
--             end,
--           },
--         })
--       end,
--       section = "",
--     },
--
--     {
--       name = "File Browser",
--       action = function()
--         require("mini.files").open(vim.loop.cwd())
--       end,
--       section = "",
--     },
--
--     {
--       name = "Quit Neovim",
--       action = "qa",
--       section = "",
--     },
--   },
--
--   content_hooks = {
--     starter.gen_hook.adding_bullet("– "),
--     starter.gen_hook.aligning("center", "center"),
--   },
-- })

-- Mini Completion ----------------------------------------------------------
do
  local process_items_opts = { kind_priority = { Text = 99, Snippet = 99 } }

  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end

  require('mini.completion').setup({
    window = {
      info = { height = 25, width = 80 },
      signature = { height = 25, width = 80 },
    },
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    end,
    desc = "Set omnifunc",
  })

  vim.lsp.config('*', {
    capabilities = MiniCompletion.get_lsp_capabilities(),
  })
end

-- Mini Diff ---------------------------------------------------------------
require('mini.diff').setup({
  view = {
    style = "sign",
    signs = { add = '󰄛', change = '▒', delete = '消' },
  },
})

-- Mini Files ---------------------------------------------------------------
do
  require('mini.files').setup({
    windows = {
      preview = true,
      width_focus = 30,
      width_nofocus = 15,
      width_preview = 85,
    },
    mappings = {
      go_in_plus = "<CR>",
      synchronize = "<Leader>w",
    },
  })

  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesExplorerOpen',
    callback = function()
      MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
      MiniFiles.set_bookmark('p',
        vim.fn.stdpath('data') .. '/site/pack/*',
        { desc = 'Plugins' }
      )
      MiniFiles.set_bookmark('w', vim.fn.getcwd(), { desc = 'Working dir' })
    end,
  })
end

-- Mini Git ---------------------------------------------------------------
require('mini.git').setup()
-- Ind   =================================================================
require('mini.indentscope').setup()
require('mini.cursorword').setup()


-- keymap==================================================================
require('mini.keymap').setup()
MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })

--HitPatterns ===========================================================
do
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end

-- Mini Pairs ---------------------------------------------------------------
require('mini.pairs').setup({
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
})

-- Mini Pick ---------------------------------------------------------------
require('mini.pick').setup()

-- Mini Surround -----------------------------------------------------------
require('mini.surround').setup()

require('mini.cmdline').setup()

-- Mini Clue ---------------------------------------------------------------
do
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
end



-- Starter ================================================================================
Mvim_starter_custom = function()
  return {
    { name = "Quit Neovim", action = "qa", section = "", },
    -- { name = "Recent Files", action = function() require("mini.extra").pickers.oldfiles() end, section = "Search" },
    -- { name = "Session",      action = function() require("mini.sessions").select() end,        section = "Search" },
  }
end

require("mini.starter").setup({
  autoopen = true,
  items = {
    -- require("mini.starter").sections.builtin_actions(),
    Mvim_starter_custom(),
    require("mini.starter").sections.recent_files(5, false, false),
    require("mini.starter").sections.recent_files(5, true, false),
    require("mini.starter").sections.sessions(5, true),
  },
  header = function()
    local v = vim.version()
    local versionstring = string.format("  Neovim Version: %d.%d.%d", v.major, v.minor, v.patch)
    local image = [[
┌─────────────────────────────────────────┐
│                                         │
│    ███╗   ███╗██╗   ██╗██╗███╗   ███╗   │
│    ████╗ ████║██║   ██║██║████╗ ████║   │
│    ██╔████╔██║██║   ██║██║██╔████╔██║   │
│    ██║╚██╔╝██║╚██╗ ██╔╝██║██║╚██╔╝██║   │
│    ██║ ╚═╝ ██║ ╚████╔╝ ██║██║ ╚═╝ ██║   │
│    ╚═╝     ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝   │
└─────────────────────────────────────────┘
]]
    finalimage = image .. versionstring
    return finalimage
  end
})


