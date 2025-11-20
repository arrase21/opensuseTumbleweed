local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

local function inlay_hint()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
  vim.notify(
    vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) and "Inlay hints: ON" or "Inlay hints: OFF",
    vim.log.levels.INFO
  )
end

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap('[p', '<Cmd>exe "put! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "put "  . v:register<CR>', 'Paste Below')

-- Clue mappings =======================================================

_G.Config.leader_group_clues = {

  { mode = 'n', keys = '<Leader>b', desc = '󰓩  Buffers' },
  { mode = 'n', keys = '<Leader>d', desc = '  Debug' },
  { mode = 'n', keys = '<Leader>f', desc = '󰱼 Find' },
  { mode = 'n', keys = '<Leader>e', desc = ' Explore/Edit' },
  { mode = 'n', keys = '<Leader>g', desc = '󰘬 Git' },
  { mode = 'n', keys = '<Leader>l', desc = ' Language' },
  { mode = 'n', keys = '<Leader>o', desc = '󰚩 Other' },
  { mode = 'n', keys = '<Leader>q', desc = '󰗼  Quit/Session' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end
nmap_leader('ba', '<Cmd>b#<CR>', 'Alternate')
nmap_leader('bs', new_scratch_buffer, 'Scratch')
nmap_leader("bp", "<cmd>bprevious<cr>", "Prev Buffer")
nmap_leader("bb", "<cmd>bnext<cr>", "Next Buffer")
nmap_leader("bd", "<cmd>:bwipeout <cr>", "Delete Buffer")
nmap_leader("b`", "<cmd>e #<cr>", "Switch to Other Buffer")

-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files =====================
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.fn.getwininfo(win_id)[1].quickfix == 1 then return vim.cmd('cclose') end
  end
  vim.cmd('copen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>', 'Directory')
nmap_leader('ef', explore_at_file, 'File directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>', 'init.lua')
nmap_leader('ek', edit_plugin_file('20_keymaps.lua'), 'Keymaps config')
nmap_leader('em', edit_plugin_file('30_mini.lua'), 'MINI config')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eo', edit_plugin_file('10_options.lua'), 'Options config')
nmap_leader('ep', edit_plugin_file('40_plugins.lua'), 'Plugins config')
nmap_leader('eq', explore_quickfix, 'Quickfix')


-- f is for 'Fuzzy Find'. Common usage: ==============================================
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
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
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>', 'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>', 'Lines (buf)')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>', 'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>', 'Modified hunks (buf)')
nmap_leader("fo", "<Cmd>lua MiniFiles.open()<CR>", "󰱼 Find Files")
nmap_leader('fp', '<Cmd>Pick projects<CR>', 'Projects')
nmap_leader('fr', '<Cmd>Pick resume<CR>', 'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>', 'References (LSP)')
nmap_leader('fs', '<Cmd>Pick lsp scope="workspace_symbol"<CR>', 'Symbols workspace')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>', 'Symbols document')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>', 'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>', 'Visit paths (cwd)')

-- g is for 'Git'. Common usage: =========================================================
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'
nmap_leader('ga', '<Cmd>Git diff --cached<CR>', 'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>', 'Added diff buffer')
nmap_leader('gc', '<Cmd>Git commit<CR>', 'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>', 'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>', 'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>', 'Diff buffer')
nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>', 'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>', 'Log buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at cursor')

xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l is for 'Language'. Common usage: ======================================================
local formatting_cmd = '<Cmd>lua require("conform").format({lsp_fallback=true})<CR>'
nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>', 'Diagnostic popup')
nmap_leader('lf', formatting_cmd, 'Format')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>', 'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', 'Hover')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>', 'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>', 'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')
xmap_leader('lf', formatting_cmd, 'Format selection')

-- o is for 'Other'. Common usage:
nmap_leader("oa", "gg<S-v>G", 'select all')
nmap_leader('oh', inlay_hint, 'Inlay')
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader("os", ":split<Return>", 'split')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>', 'Trim trailspace')
nmap_leader("ov", ":vsplit<Return>", 'split vertical')
nmap_leader("oy", "mzyyp`zj", "copy/paste")
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>', 'Zoom toggle')

-- s is for 'Session'. Common usage:
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>', 'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>', 'Read')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>', 'Write current')

-- t is for 'Terminal'
nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>', 'Terminal (vertical)')

local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('', 'Core visits (all)'), 'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'), 'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>', 'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>', 'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>', 'Remove label')

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("i", "kj", "<ESC>", opts)
map("i", "KJ", "<ESC>", opts)
-- Wrire
map("n", "<Leader>w", ":w<ESC>", { desc = "write" })
-- Delete word
map("n", "<backspace>", "diw", opts)
-- Delete a word backwards
map("n", "dw", 'vb"_d')
-- Move text up and down
map("v", "<A-j>", ":m .+1<CR>==", opts)
map("v", "<A-k>", ":m .-2<CR>==", opts)
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Select
map("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true })
map("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, noremap = true })

-- Confirmar con Enter
map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  end
  return "<CR>"
end, { expr = true, noremap = true })
-- stylua: ignore end
