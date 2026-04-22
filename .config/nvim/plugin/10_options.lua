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
vim.o.winborder       = "rounded" -- Rounded floating windows
vim.o.pumborder       = "rounded" -- Rounded floating windows
vim.o.showtabline     = 2         -- Always show tabs
vim.o.signcolumn      = "yes"     -- Always show sign column
vim.o.cursorcolumn    = false     -- Highlight current column
-- vim.opt.termguicolors = true      -- True color support
vim.o.cursorline      = true      -- Enable current line highlighting
vim.o.colorcolumn     = '+1'      -- Draw column on the right of maximum width
vim.o.termguicolors   = true
-- Special UI symbols
vim.o.fillchars       = 'eob: ,fold:╌' -- End-of-buffer and fold chars
vim.o.listchars       = 'extends:…,precedes:…,nbsp:␣,tab:  ,'

-- Folds =======================================================================
vim.o.foldlevel       = 1        -- Fold nothing by default
vim.o.foldmethod      = 'indent' -- Fold based on indent
vim.o.foldnestmax     = 10       -- Max fold levels
vim.o.foldtext        = ''       -- Use default fold text

-- Editing =====================================================================
vim.o.tabstop         = 2                                     -- Tab width
vim.o.expandtab       = true                                  -- Convert tabs to spaces
vim.o.shiftwidth      = 2                                     -- Indent width
vim.o.smartindent     = true                                  -- Smart auto-indent
vim.o.ignorecase      = true                                  -- Ignore case during search
vim.o.incsearch       = true                                  -- Show search matches while typing

vim.o.complete        = '.,w,b,kspell'                        -- Use less sources
vim.o.completeopt     = 'menuone,noinsert,fuzzy,nosort,popup' -- Use custom behavior
-- vim.o.autocomplete = true
vim.o.completetimeout = 200                                   -- Limit sources delay
-- o.autocomplete = true
-- vim.o.complete        = "o,.,w,b,u"
vim.opt.shortmess:prepend("c") -- avoid having to press enter on snippet completion

-- Autocommands ================================================================
Config.new_autocmd('FileType', nil, function()
  vim.cmd('setlocal formatoptions-=c formatoptions-=o')
end, "Proper 'formatoptions'")

-- Diagnostics ================================================================
local diagnostic_opts = {
  signs            = {
    priority = 9999,
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  -- virtual_text     = false,
  underline        = true,
  virtual_lines    = false,
  virtual_text     = {
    prefix = '󰅚',
    source = "if_many",
    severity = { min = 'WARN', max = 'ERROR' },
    spacing = 4,
  },
  update_in_insert = false,
}

Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
