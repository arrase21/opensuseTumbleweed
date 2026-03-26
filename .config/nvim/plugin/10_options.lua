-- General ====================================================================
vim.g.mapleader   = ' '                                     -- Leader key
vim.o.mouse       = 'a'                                     -- Enable mouse
vim.o.mousescroll = 'ver:25,hor:6'                          -- Scroll speed
vim.o.undofile    = true                                    -- Persistent undo
vim.o.clipboard   = vim.env.SSH_TTY and '' or 'unnamedplus' -- System clipboard if not SSH

-- Enable filetype plugins and syntax
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

-- UI =========================================================================
vim.o.number          = true      -- Absolute line numbers
vim.o.relativenumber  = true      -- Relative line numbers
vim.o.cmdheight       = 0         -- Hide command line (use statusline)
vim.o.confirm         = true      -- Confirm unsaved changes
vim.opt.winborder     = "rounded" -- Rounded floating windows
vim.opt.pumborder     = "rounded" -- Rounded floating windows
vim.opt.showtabline   = 2         -- Always show tabs
vim.opt.signcolumn    = "yes"     -- Always show sign column
vim.opt.cursorcolumn  = false     -- Highlight current column
vim.opt.termguicolors = true      -- True color support
vim.o.cursorline      = true      -- Enable current line highlighting

-- Special UI symbols
vim.o.fillchars       = 'eob: ,fold:╌' -- End-of-buffer and fold chars
vim.o.listchars       = 'extends:…,precedes:…,nbsp:␣,tab:  ,'

-- Folds =======================================================================
vim.o.foldlevel       = 1        -- Fold nothing by default
vim.o.foldmethod      = 'indent' -- Fold based on indent
vim.o.foldnestmax     = 10       -- Max fold levels
vim.o.foldtext        = ''       -- Use default fold text

-- Editing =====================================================================
vim.opt.tabstop       = 2    -- Tab width
vim.opt.shiftwidth    = 2    -- Indent width
vim.opt.smartindent   = true -- Smart auto-indent

-- Built-in completion
vim.o.completetimeout = 100 -- Limit completion sources delay

-- Autocommands ================================================================
Config.new_autocmd('FileType', nil, function()
	vim.cmd('setlocal formatoptions-=c formatoptions-=o')
end, "Proper 'formatoptions'")

-- Diagnostics ================================================================
local diagnostic_opts = {
	signs            = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN]  = " ",
			[vim.diagnostic.severity.HINT]  = "󰌵 ",
			[vim.diagnostic.severity.INFO]  = " ",
		},
		linehl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
		},
		numhl = {
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
	virtual_text     = true,
	underline        = { severity = { min = vim.diagnostic.severity.HINT } },
	virtual_lines    = false,
	update_in_insert = false,
}
Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
