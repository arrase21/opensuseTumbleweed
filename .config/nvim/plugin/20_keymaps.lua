local function lazygit()
  local w, h = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
  local buf  = vim.api.nvim_create_buf(false, true)
  local win  = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
  })
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.fn.termopen("lazygit", { on_exit = close })
  vim.keymap.set("n", "q", close, { buffer = buf })
  vim.cmd.startinsert()
end
local function inlay_hint()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
  vim.notify(
    vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) and "Inlay hints: ON" or "Inlay hints: OFF",
    vim.log.levels.INFO
  )
end

local function pack_clean()
  local active_plugins = {}
  local unused_plugins = {}
  for _, plugin in ipairs(vim.pack.get()) do
    active_plugins[plugin.spec.name] = plugin.active
  end
  for _, plugin in ipairs(vim.pack.get()) do
    if not active_plugins[plugin.spec.name] then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end
  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end
  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end
-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

nmap('[p', '<Cmd>exe "iput! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "iput "  . v:register<CR>', 'Paste Below')

-- Leader mappings ============================================================
Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '󰓩  Buffers' },
  { mode = 'n', keys = '<Leader>d', desc = '  Debug' },
  { mode = 'n', keys = '<Leader>f', desc = '󰱼 Find' },
  { mode = 'n', keys = '<Leader>e', desc = ' Explore/Edit' },
  { mode = 'n', keys = '<Leader>g', desc = '󰘬 Git' },
  { mode = 'n', keys = '<Leader>r', desc = '󰗼  kulala/rest' },
  { mode = 'n', keys = '<Leader>l', desc = ' Language' },
  { mode = 'n', keys = '<Leader>o', desc = '󰚩 Other' },
  { mode = 'n', keys = '<Leader>q', desc = '󰗼  Quit/Session' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },
  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end
local nmap_leader = function(suffix, rhs, desc) map('n', '<Leader>' .. suffix, rhs, desc) end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end
nmap_leader('bd', '<cmd>bwipeout<cr>', 'Delete')

-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>', 'Directory')
nmap_leader('ef', explore_at_file, 'File directory')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eq', explore_quickfix, 'Quickfix list')
nmap_leader('eQ', explore_locations, 'Location list')
nmap_leader('et', '<Cmd>NvimTreeOpen()<CR>', 'NerdTree')


local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'
nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>', '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>', '":" history')
nmap_leader('fa', '<Cmd>Pick git_hunks scope="staged"<CR>', 'Added hunks (all)')
nmap_leader('fA', pick_added_hunks_buf, 'Added hunks (buf)')
nmap_leader('fb', '<Cmd>Pick buffers<CR>', 'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>', 'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>', 'Commits (buf)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="all"<CR>', 'Diagnostic workspace')
nmap_leader('fD', '<Cmd>Pick diagnostic scope="current"<CR>', 'Diagnostic buffer')
nmap_leader('ff', '<Cmd>Pick files<CR>', 'Files')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>', 'Grep live')
nmap_leader('fG', '<Cmd>Pick grep pattern="<cword>"<CR>', 'Grep current word')
nmap_leader('fh', '<Cmd>Pick help<CR>', 'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>', 'Highlight groups')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>', 'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>', 'Modified hunks (buf)')
nmap_leader('fr', '<Cmd>Pick resume<CR>', 'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>', 'References (LSP)')
nmap_leader('fs', pick_workspace_symbols_live, 'Symbols workspace (live)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>', 'Symbols document')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>', 'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>', 'Visit paths (cwd)')

nmap_leader('gg', lazygit, 'Lazygit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>', 'Commit amend')

local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'
nmap_leader('ga', '<Cmd>Git diff --cached<CR>', 'Added diff')
nmap_leader('gc', '<Cmd>Git commit<CR>', 'Commit')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>', 'Added diff buffer')
nmap_leader('gb', '<Cmd>lua MiniExtra.pickers.git_branches()<CR>', 'Lazygit')
nmap_leader('gl', '<Cmd>lua MiniExtra.pickers.git_commits()<CR>', 'Lazygit')
nmap_leader('gb', function()
  local branch = vim.fn.system('git branch --list --format="%(refname:short)"')
  MiniPick.start({
    source = {
      items = vim.split(branch, '\n'),
      name = 'Git Branches',
      choose = function(item)
        vim.fn.system('git checkout ' .. item)
        vim.notify('Switched to branch: ' .. item)
        vim.cmd('checktime')
      end,
    },
  })
end, 'Git branches')

nmap_leader('gl', function()
  local commits = vim.fn.system('git log --oneline -50')
  MiniPick.start({
    source = {
      items = vim.split(vim.trim(commits), '\n'),
      name = 'Git Commits',
      choose = function(item)
        local hash = item:match('^(%x+)')
        vim.fn.system('git checkout ' .. hash)
        vim.notify('Checked out: ' .. hash)
        vim.cmd('checktime')
      end,
    },
  })
end, 'Git commits')
nmap_leader('gd', '<Cmd>Git diff<CR>', 'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>', 'Diff buffer')
-- nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>', 'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>', 'Log buffer')

nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Actions')
nmap_leader('ld', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')
nmap_leader('lD', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Prev Diagnostic')
nmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>', 'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', 'Hover')
nmap_leader('ll', '<Cmd>lua vim.lsp.codelens.run()<CR>', 'Lens')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>', 'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>', 'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')
xmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format selection')

-- o is for 'Other'. Common usage:
nmap_leader("oa", "gg<S-v>G", 'select all')
nmap_leader('oh', inlay_hint, 'Inlay')
nmap_leader('oc', pack_clean, 'Uninstall plugin')
nmap_leader('ou', '<Cmd>lua vim.pack.update()<CR>', 'Update plugin')
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader("os", ":split<Return>", 'split')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>', 'Trim trailspace')
nmap_leader("ov", ":vsplit<Return>", 'split vertical')
nmap_leader("oy", "mzyyp`zj", "copy/paste")
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>', 'Zoom toggle')


local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'
nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>', 'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>', 'Read')
nmap_leader('sR', '<Cmd>lua MiniSessions.restart()<CR>', 'Restart')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>', 'Write current')

local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end
nmap_leader('vc', make_pick_core('', 'Core visits (all)'), 'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'), 'Core visits (cwd)')
nmap_leader('va', '<Cmd>lua MiniExtra.pickers.visit_labels()<CR>', 'View all label')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>', 'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>', 'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>', 'Remove label')

-- 4. Globales ================================================================
-- Navegación entre ventanas
map('n', '<C-h>', '<C-w>h', 'Window Left')
map('n', '<C-j>', '<C-w>j', 'Window Down')
map('n', '<C-k>', '<C-w>k', 'Window Up')
map('n', '<C-l>', '<C-w>l', 'Window Right')

-- Mover líneas
map("n", "<A-j>", ":m .+1<CR>==", 'Move line down')
map("n", "<A-k>", ":m .-2<CR>==", 'Move line up')

-- Escape en insert mode
map('i', 'kj', '<ESC>', 'Escape')
map('i', 'KJ', '<ESC>', 'Escape')

-- Quit / Write
map("n", "<leader>qq", "<cmd>qa<cr>", "Quit All")
map("n", "<leader>qa", "<cmd>q<cr>", "Quit")
map('n', '<leader>w', '<Cmd>w<CR>', 'Write')

-- Misc
map('n', '<backspace>', 'diw', 'Delete word')

-- Resize ventanas
map("n", "<C-A-k>", "<cmd>resize +2<cr>", "Increase Window Height")
map("n", "<C-A-j>", "<cmd>resize -2<cr>", "Decrease Window Height")
map("n", "<C-A-L>", "<cmd>vertical resize -2<cr>", "Decrease Window Width")
map("n", "<C-A-h>", "<cmd>vertical resize +2<cr>", "Increase Window Width")

nmap_leader('rs', function() require('kulala').run() end, 'Send request')
-- stylua: ignore end


vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, noremap = true })

-- Confirmar con Enter
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  end
  return "<CR>"
end, { expr = true, noremap = true })
