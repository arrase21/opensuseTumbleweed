-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Step one ===================================================================
-- Mini Icons ========================================================================
now(function()
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })
  later(MiniIcons.mock_nvim_web_devicons)
  later(MiniIcons.tweak_lsp_kind)
end)

-- Mini Misc ==========================================================================
-- Uses `now()` for `setup_xxx()` to work when started like `nvim -- path/to/file`
now_if_args(function()
  require('mini.misc').setup()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
  MiniMisc.setup_termbg_sync()
end)
-- Mini Session ========================================================================
now(function() require('mini.sessions').setup() end)

-- Mini Notify ==========================================================================
now(function()
  local predicate = function(notif)
    if not (notif.data.source == 'lsp_progress' and notif.data.client_name == 'lua_ls') then return true end
    return notif.msg:find('Diagnosing') == nil and notif.msg:find('semantic tokens') == nil
  end
  local custom_sort = function(notif_arr) return MiniNotify.default_sort(vim.tbl_filter(predicate, notif_arr)) end

  require('mini.notify').setup({ content = { sort = custom_sort } })
end)

-- Mini tabline ==========================================================================
now(function() require('mini.tabline').setup() end)

-- Mini Extra ============================================================================
later(function() require('mini.extra').setup() end)

-- Mini Comment ==========================================================================
later(function() require('mini.comment').setup() end)

-- Mini Completion =======================================================================
now(function()
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require('mini.completion').setup({
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })
  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
  _G.Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")
  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- Mini Diff ========================================================================
later(function()
  require('mini.diff').setup({
    view = {
      style = "sign",
      signs = { add = '󰄛', change = '▒', delete = '消' },
    }
  })
end)

-- Mini Files ========================================================================
later(function()
  require('mini.files').setup(
    {
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
  local add_marks = function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    local minideps_plugins = vim.fn.stdpath('data') .. '/site/pack/deps/opt'
    MiniFiles.set_bookmark('p', minideps_plugins, { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end
  _G.Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
end)

-- Mini Git ========================================================================
later(function() require('mini.git').setup() end)

-- Mini indentscope ========================================================================
later(function() require('mini.indentscope').setup() end)

-- Mini Pairs ========================================================================
later(function()
  require('mini.pairs').setup({ modes = { command = true } })
end)

-- Mini Pick ========================================================================
later(function() require('mini.pick').setup() end)

-- Mini Surroud ========================================================================
later(function() require('mini.surround').setup() end)

-- Mini Clue ========================================================================
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
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = 'n', keys = '<Leader>' }, -- Leader triggers
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = [[\]] },      -- mini.basics
      { mode = 'n', keys = '[' },        -- mini.bracketed
      { mode = 'n', keys = ']' },
      { mode = 'x', keys = '[' },
      { mode = 'x', keys = ']' },
      { mode = 'i', keys = '<C-x>' }, -- Built-in completion
      { mode = 'n', keys = 'g' },     -- `g` key
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },     -- Marks
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' }, -- Registers
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' }, -- Window commands
      { mode = 'n', keys = 'z' },     -- `z` key
      { mode = 'x', keys = 'z' },
    },
  })
end)
