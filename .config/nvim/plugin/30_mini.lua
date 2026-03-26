-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Step one ===================================================================
now(function()
	-- Set up to not prefer extension-based icon for some extensions
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

now(function() require('mini.notify').setup() end)

now(function() require('mini.sessions').setup() end)

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
	local process_items_opts = { kind_priority = { Text = 1, Snippet = 99 } }
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
	Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")
	vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

now_if_args(function()
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
	MiniMisc.setup_termbg_sync()
end)

-- Step two ===================================================================
later(function() require('mini.extra').setup() end)
-- later(function() require('mini.animate').setup() end)

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

later(function() require('mini.cmdline').setup() end)

later(function() require('mini.comment').setup() end)

later(function() require('mini.cursorword').setup() end)

later(function()
	require('mini.diff').setup({
		view = {
			style = "sign",
			signs = { add = '󰄛', change = '▒', delete = '消' },
		},
	})
end)

later(function() require('mini.git').setup() end)


later(function() require('mini.indentscope').setup() end)

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
		scroll_preview_down = { char = '', func = function() end },
		scroll_preview_up   = { char = '', func = function() end },

		preview_down        = {
			char = '<C-d>',
			func = function()
				local win = require("preview.windows").preview_win
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_call(win, function()
						vim.cmd("normal! 5\x05") -- 5<C-e>
					end)
				end
			end,
		},
		preview_up          = {
			char = '<C-u>',
			func = function()
				local win = require("preview.windows").preview_win
				if win and vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_call(win, function()
						vim.cmd("normal! 5\x19") -- 5<C-y>
					end)
				end
			end,
		},
	},
})


-- require('mini.pick').setup({
-- 	mappings = {
-- 		scroll_preview_down = {
-- 			char = '<C-d>',
-- 			func = function()
-- 				local win = require("preview.windows").preview_win
-- 				if win and vim.api.nvim_win_is_valid(win) then
-- 					vim.api.nvim_win_call(win, function()
-- 						vim.cmd("normal! 5\x05") -- 5<C-e>
-- 					end)
-- 				end
-- 			end,
-- 		},
-- 		scroll_preview_up = {
-- 			char = '<C-u>',
-- 			func = function()
-- 				local win = require("preview.windows").preview_win
-- 				if win and vim.api.nvim_win_is_valid(win) then
-- 					vim.api.nvim_win_call(win, function()
-- 						vim.cmd("normal! 5\x19") -- 5<C-y>
-- 					end)
-- 				end
-- 			end,
-- 		},
-- 	},
-- })
--

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
			-- Always load 'snippets/global.json' from config directory
			snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
			-- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})
end)

--Surround ======================================================================================================================
later(function()
	require('mini.surround').setup({

	})
end)

--Starter =======================================================================================================================
Mvim_starter_custom = function()
	return {
		{ name = "Quit Neovim",  action = "qa",                                                    section = "", },
		{ name = "Recent Files", action = function() require("mini.extra").pickers.oldfiles() end, section = "Search" },
		-- { name = "Session",      action = function() require("mini.sessions").select() end,        section = "Search" },
	}
end


require("mini.starter").setup({
	autoopen = true,
	items = {
		Mvim_starter_custom(),
		require("mini.starter").sections.recent_files(3, false, false),
		require("mini.starter").sections.recent_files(3, true, false),
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
		return image .. versionstring
	end,
	footer = "",          -- <-- quitar footer
	query_updater = false, -- <-- desactiva la línea de query
})


--StatusLine ===========================================================================================================

local colors = {
	blue    = '#51afef',
	green   = '#98be65',
	magenta = '#c678dd',
	yellow  = '#ECBE7B',
	cyan    = '#008080',
	red     = '#ec5f67',
	fg      = '#bbc2cf',
	bg      = '#202328',
}

local mode_colors = {
	n = colors.red,
	i = colors.green,
	v = colors.blue,
	V = colors.blue,
	['\22'] = colors.blue,
	c =
			colors.magenta,
	R = colors.magenta
}

-- HL helper
local function hl(name, opts)
	vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', { bg = 'NONE' }, opts))
end

local function set_hl()
	hl('SLMode', { bold = true })
	hl('SLFile', { fg = colors.magenta, bold = true })
	hl('SLFileInfo', { fg = colors.fg })
	hl('SLSysInfo', { fg = colors.green })
	hl('SLLsp', { fg = '#ffffff', bold = true })
	hl('SLInfo', { fg = colors.fg })
	hl('SLCrumb', { fg = '#888888' })
	hl('Err', { fg = colors.red })
	hl('Warn', { fg = colors.yellow })
	hl('Info', { fg = colors.cyan })
	hl('Hint', { fg = colors.blue })
	hl('SLGitBranch', { fg = '#cccccc' })
	hl('SLGitAdd', { fg = colors.green })
	hl('SLGitChange', { fg = colors.yellow })
	hl('SLGitDel', { fg = colors.red })
	hl('LualineFolder', { fg = '#fab387' })
	hl('LualineSeparator', { fg = '#585b70' })
	hl('LualineFileName', { fg = '#ffffff' })
end
set_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })

-- Generic cache helper
local function make_cache(fn, events)
	local cache = { val = nil, buf = -1 }
	if events then
		vim.api.nvim_create_autocmd(events, { callback = function() cache = { val = nil, buf = -1 } end })
	end
	return function()
		local buf = vim.api.nvim_get_current_buf()
		if buf == cache.buf and cache.val ~= nil then return cache.val end
		cache.val = fn(buf)
		cache.buf = buf
		return cache.val
	end
end

local lsp = make_cache(function(buf)
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do return c.name end
	return 'No LSP'
end, { 'LspAttach', 'LspDetach' })

local filesize = make_cache(function(buf)
	if vim.bo.buftype ~= '' then return '' end
	local name = vim.api.nvim_buf_get_name(buf)
	if name == '' then return '' end
	local s = vim.loop.fs_stat(name)
	if not s then return '' end
	if s.size < 1024 then
		return s.size .. 'B'
	elseif s.size < 1024 * 1024 then
		return string.format('%.1fK', s.size / 1024)
	else
		return string.format('%.1fM', s.size / (1024 * 1024))
	end
end, { 'BufEnter', 'BufWritePost' })

local breadcrumbs = make_cache(function(buf)
	if vim.bo.buftype ~= '' then return '' end
	local ok, mod = pcall(require, 'utils.breadcrumbs')
	return ok and mod.get() or ''
end)

-- Diagnostics
local function diag()
	local d = vim.diagnostic.get(0)
	if not next(d) then return '' end
	local count = { 0, 0, 0, 0 }
	for _, v in ipairs(d) do count[v.severity] = count[v.severity] + 1 end
	local symbols = { '', '', '', '󰌵' }
	local parts = {}
	for i = 1, 4 do
		if count[i] > 0 then
			parts[#parts + 1] = ('%%#%s# %s %d'):format(({ 'Err', 'Warn', 'Info', 'Hint' })
				[i], symbols[i], count[i])
		end
	end
	return table.concat(parts, ' ') .. '%#SLFileInfo#'
end

-- Git
local function git()
	local b = vim.b
	local head = (b.minigit_summary and b.minigit_summary.head_name) or ''
	local added, changed, removed = (b.minidiff_summary and b.minidiff_summary.add or 0),
			(b.minidiff_summary and b.minidiff_summary.change or 0),
			(b.minidiff_summary and b.minidiff_summary.delete or 0)
	if head == '' and added + changed + removed == 0 then return '' end
	local parts = { '%#SLGitBranch#  ' .. head }
	if added > 0 then parts[#parts + 1] = '%#SLGitAdd#  ' .. added end
	if changed > 0 then parts[#parts + 1] = '%#SLGitChange# 󰝤 ' .. changed end
	if removed > 0 then parts[#parts + 1] = '%#SLGitDel#  ' .. removed end
	return table.concat(parts, ' ') .. '%#SLInfo#'
end

require('mini.statusline').setup({
	content = {
		active = function()
			local mode = vim.fn.mode()
			vim.api.nvim_set_hl(0, 'SLMode', { fg = mode_colors[mode] or colors.blue, bg = 'NONE', bold = true })
			local file = vim.fn.expand('%:t'); if file == '' then file = '[No Name]' end
			local parts = {
				'%#SLMode#▊  ',
				(filesize() ~= '' and ('%#SLFileInfo#' .. filesize() .. ' ')) or '',
				'%#SLFile#' .. file .. (vim.bo.modified and ' [+] ' or ' '),
				(breadcrumbs() ~= '' and ('%#SLCrumb#' .. breadcrumbs() .. ' ')) or '',
				'%#SLFileInfo# %l:%c  %p%% ',
				diag(),
				'%=',
				'%#SLLsp# LSP: ' .. lsp() .. ' ',
				'%=',
				'%#SLSysInfo#' ..
				(vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding):upper() ..
				' ' .. vim.bo.fileformat:upper() .. ' ',
				(git() ~= '' and (git() .. ' ')) or '',
				'%#SLMode#▊',
			}
			return table.concat(parts)
		end,
		inactive = function() return '%#SLInfo# %f %=' end,
	},
})
