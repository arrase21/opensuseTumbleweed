-- 1. Definición de Grupos para mini.clue
Config.leader_group_clues = {
	{ mode = 'n', keys = '<Leader>b', desc = '󰓩  Buffers' },
	{ mode = 'n', keys = '<Leader>d', desc = '  Debug' },
	{ mode = 'n', keys = '<Leader>f', desc = '󰱼 Find' },
	{ mode = 'n', keys = '<Leader>e', desc = ' Explore/Edit' },
	{ mode = 'n', keys = '<Leader>g', desc = '󰘬 Git' },
	{ mode = 'n', keys = '<Leader>l', desc = ' Language' },
	{ mode = 'n', keys = '<Leader>o', desc = '󰚩 Other' },
	{ mode = 'n', keys = '<Leader>q', desc = '󰗼  Quit/Session' },
	{ mode = 'n', keys = '<Leader>r', desc = '󰗼  kulala/rest' },
	{ mode = 'n', keys = '<Leader>s', desc = '+Session' },
	{ mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
	{ mode = 'n', keys = '<Leader>v', desc = '+Visits' },
	{ mode = 'x', keys = '<Leader>g', desc = '+Git' },
	{ mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

-- 2. Funciones de Soporte y Variables (DEFINIR ANTES DE USAR)
local function pack_clean()
	local active = {}
	for _, p in ipairs(vim.pack.get()) do active[p.spec.name] = p.active end
	local unused = {}
	for _, p in ipairs(vim.pack.get()) do
		if not active[p.spec.name] then table.insert(unused, p.spec.name) end
	end
	if #unused == 0 then return print("No unused plugins.") end
	if vim.fn.confirm("Remove unused?", "&Yes\n&No", 2) == 1 then vim.pack.del(unused) end
end

local function inlay_hint()
	local buf = vim.api.nvim_get_current_buf()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
end

local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end
local nmap_leader = function(suffix, rhs, desc) map('n', '<Leader>' .. suffix, rhs, desc) end

-- Variables para Pickers
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'
local git_picker = function(args, title)
	return function()
		MiniPick.builtin.cli({ command = { 'git', unpack(args) } }, { source = { name = title } })
	end
end
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'
local cfg_path = vim.fn.stdpath('config') .. '/plugin/'

-- 3. Mapeos Lógicos ==========================================================

-- [b] Buffers
nmap_leader('ba', '<Cmd>b#<CR>', 'Alternate')
nmap_leader('bs', function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end, 'Scratch')
nmap_leader('bn', '<cmd>bnext<cr>', 'Next')
nmap_leader('bp', '<cmd>bprevious<cr>', 'Prev Buffer')
nmap_leader('bd', '<cmd>bwipeout<cr>', 'Delete')
-- [d] Debug
-- [e] Explore/Edit
nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>', 'Directory')
nmap_leader('ef', '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>', 'File directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>', 'init.lua')
nmap_leader('ek', '<Cmd>edit ' .. cfg_path .. '20_keymaps.lua<CR>', 'Keymaps config')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('em', '<Cmd>edit ' .. cfg_path .. '30_mini.lua<CR>', 'MINI config')
nmap_leader('eo', '<Cmd>edit ' .. cfg_path .. '10_options.lua<CR>', 'Options config')
nmap_leader('ep', '<Cmd>edit ' .. cfg_path .. '40_plugins.lua<CR>', 'Plugins config')
-- nmap_leader('eq', explore_quickfix, 'Quickfix list')
-- nmap_leader('eQ', explore_locations, 'Location list')

-- [f] Find (Todos tus pickers originales)
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
nmap_leader('fr', '<Cmd>Pick resume<CR>', 'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>', 'References (LSP)')
nmap_leader('fs', pick_workspace_symbols_live, 'Symbols workspace (live)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>', 'Symbols document')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>', 'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>', 'Visit paths (cwd)')

-- [g] Git (Diffs, Commits y Pickers avanzados)
nmap_leader('ga', '<Cmd>Git diff --cached<CR>', 'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>', 'Added diff buffer')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>', 'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>', 'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>', 'Diff buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gh', '<Cmd>lua require("mini.git").show_at_cursor()<CR>', 'Show at cursor')
nmap_leader('gs', function() git_picker({ 'status', '-s' }, 'Git Status')() end, 'Git Status')
nmap_leader('gS', function() git_picker({ 'stash', 'list' }, 'Git Stash')() end, 'Git Stash')
nmap_leader('gL', function() git_picker({ 'log', '--oneline', '--follow', '--', vim.fn.expand('%') }, 'Log Buffer')() end,
	'Log buffer')

nmap_leader('gb', function()
	local items = vim.fn.systemlist('git branch -a --format="%(refname:short)"')
	MiniPick.start({
		source = {
			items = items,
			name = 'Git Branches',
			choose = function(item)
				local out = vim.fn.system({ 'git', 'checkout', item })
				vim.notify(out)
			end,
			preview = function(buf_id, item)
				local out = vim.fn.systemlist({ 'git', 'log', '-1', '--stat', item })
				vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, out)
				vim.api.nvim_buf_set_option(buf_id, "filetype", "git")
			end
		}
	})
end, 'Git Branches')

nmap_leader('gl', function()
	local items = vim.fn.systemlist('git log --pretty=format:"%h %s" -n 50')
	MiniPick.start({
		source = {
			items = items,
			name = 'Git Checkout Commit',
			choose = function(item)
				local hash = string.sub(item, 1, 7)
				vim.schedule(function()
					local output = vim.fn.system({ 'git', 'checkout', hash })
					if vim.v.shell_error ~= 0 then
						vim.notify("Error: " .. output, vim.log.levels.ERROR)
					else
						vim.notify("Cambiado a: " .. hash)
						vim.cmd('checktime')
					end
				end)
			end,
		}
	})
end, 'Git Log (Checkout)')

-- [l] Language
nmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format')
nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Actions')
nmap_leader('ld', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')
nmap_leader('lD', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Prev Diagnostic')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>', 'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>', 'Hover')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>', 'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>', 'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')
nmap_leader("lgd", vim.lsp.buf.definition, 'Go Definition')         -- Go to definition
nmap_leader("lgy", vim.lsp.buf.type_definition, 'Go Type')          -- Go to type
nmap_leader("lgD", vim.lsp.buf.declaration, 'Go Declaration')       -- Go to declaration
nmap_leader("lgr", vim.lsp.buf.references, 'Go References')         -- Go to references
nmap_leader("lgi", vim.lsp.buf.implementation, 'Go Implementation') -- Go to implementation
-- [o] Other
nmap_leader("oa", "gg<S-v>G", 'select all')
nmap_leader("oc", pack_clean, 'Clean package')
nmap_leader('oh', inlay_hint, 'Inlay')
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader("os", ":split<Return>", 'split')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>', 'Trim trailspace')
nmap_leader("ov", ":vsplit<Return>", 'split vertical')
nmap_leader("oy", "mzyyp`zj", "copy/paste")
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>', 'Zoom toggle')

-- [s] Session
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>', 'New Session')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>', 'Read Session')
nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>', 'Write current')

nmap_leader('rs', function() require('kulala').run() end, 'Send request')

-- 4. Globales
map('n', '<C-h>', '<C-w>h', 'Window Left')
map('n', '<C-j>', '<C-w>j', 'Window Down')
map('n', '<C-k>', '<C-w>k', 'Window Up')
map('n', '<C-l>', '<C-w>l', 'Window Right')

map("n", "<A-j>", ":m .+1<CR>==", '')
map("n", "<A-k>", ":m .-2<CR>==", '')

map('i', 'kj', '<ESC>', 'Escape')
map('i', 'KJ', '<ESC>', 'Escape')
map("n", "<leader>qq", "<cmd>qa<cr>", "Quit All")
map("n", "<leader>qa", "<cmd>q<cr>", "Quit")
map('n', '<leader>w', '<Cmd>w<CR>', 'Write')

map('n', '<backspace>', 'diw', 'Delete word')


map("n", "<C-A-k>", "<cmd>resize +2<cr>", "Increase Window Height")
map("n", "<C-A-j>", "<cmd>resize -2<cr>", "Decrease Window Height")
map("n", "<C-A-L>", "<cmd>vertical resize -2<cr>", "Decrease Window Width")
map("n", "<C-A-h>", "<cmd>vertical resize +2<cr>", "Increase Window Width")

-- map("n", "gd", vim.lsp.buf.definition, '')      -- Go to definition
-- map("n", "gy", vim.lsp.buf.type_definition, '') -- Go to type
-- map("n", "gD", vim.lsp.buf.declaration, '')     -- Go to declaration
-- map("n", "gr", vim.lsp.buf.references, '')      -- Go to references
-- map("n", "gi", vim.lsp.buf.implementation, '')  -- Go to implementation
