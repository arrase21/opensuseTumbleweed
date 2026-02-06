-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- General ====================================================================
vim.g.mapleader   = ' '                              -- Use `<Space>` as <Leader> key
vim.o.mouse       = 'a'                              -- Enable mouse
vim.o.mousescroll = 'ver:25,hor:6'                   -- Customize mouse scroll
vim.o.switchbuf   = 'usetab'                         -- Use already opened buffers when switching
vim.o.undofile    = true                             -- Enable persistent undo
vim.o.shada       = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)

-- Enable all filetype plugins and syntax (if not enabled, for better startup)
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end
vim.o.clipboard       = vim.env.SSH_TTY and '' or 'unnamedplus'
-- UI =========================================================================
vim.o.termguicolors   = true                -- True color support
vim.o.breakindent     = true                -- Indent wrapped lines to match line start
vim.o.breakindentopt  = 'list:-1'           -- Add padding for lists (if 'wrap' is set)
vim.o.colorcolumn     = '+1'                -- Draw column on the right of maximum width
vim.o.cursorline      = true                -- Enable current line highlighting
vim.o.linebreak       = true                -- Wrap lines at 'breakat' (if 'wrap' is set)
vim.o.list            = true                -- Show helpful text indicators
vim.o.number          = true                -- Show line numbers
vim.o.relativenumber  = true                -- Show line numbers
vim.o.pumheight       = 10                  -- Make popup menu smaller
vim.o.ruler           = false               -- Don't show cursor coordinates
vim.o.shortmess       = 'CFOSWaco'          -- Disable some built-in completion messages
vim.o.showmode        = false               -- Don't show mode in command line
vim.o.signcolumn      = 'yes'               -- Always show signcolumn (less flicker)
vim.o.splitbelow      = true                -- Horizontal splits will be below
vim.o.splitkeep       = 'screen'            -- Reduce scroll during window split
vim.o.splitright      = true                -- Vertical splits will be to the right
vim.o.winborder       = 'single'            -- Use border in floating windows
vim.o.wrap            = false               -- Don't visually wrap lines (toggle with \w)
vim.o.cmdheight       = 0
vim.o.cursorlineopt   = 'screenline,number' -- Show cursor line per screen line
vim.o.scrolloff       = 4                   -- Lines of context
vim.o.winminwidth     = 5                   -- Minimum window width
-- Special UI symbols =================================================
vim.opt.fillchars     = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.o.listchars       = "tab:→ ,trail:·,extends:…,precedes:…"
-- Folds ==============================================================
vim.o.foldlevel       = 99
vim.o.foldmethod      = 'indent'
vim.o.foldnestmax     = 10
vim.o.foldtext        = ""
-- Editing ====================================================================
vim.o.formatoptions   = 'jcroqlnt'
vim.o.autoindent      = true                  -- Use auto indent
vim.o.expandtab       = true                  -- Convert tabs to spaces
vim.o.formatoptions   = 'rqnl1j'              -- Improve comment editing
vim.o.ignorecase      = true                  -- Ignore case during search
vim.o.incsearch       = true                  -- Show search matches while typing
vim.o.infercase       = true                  -- Infer case in built-in completion
vim.o.shiftwidth      = 2                     -- Use this number of spaces for indentation
vim.o.smartcase       = true                  -- Respect case if search pattern has upper case
vim.o.smartindent     = true                  -- Make indenting smart
vim.o.spelloptions    = 'camel'               -- Treat camelCase word parts as separate words
vim.o.tabstop         = 2                     -- Show tab as this number of spaces
vim.o.virtualedit     = 'block'               -- Allow going past end of line in blockwise mode
vim.o.confirm         = true
vim.o.iskeyword       = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part

-- vim.o.pumborder = 'rounded'

vim.o.pummaxwidth     = 100    -- Limit maximum width of popup menu
vim.o.completetimeout = 100
vim.o.pumborder       = 'bold' -- Use border in built-in completion menu
require('vim._extui').enable({ enable = true })



vim.diagnostic.config({
  signs = {
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

  float = {
    source = "always",
    header = "",
    focusable = true,
  },

  virtual_text = true,
  underline = { severity = { min = vim.diagnostic.severity.HINT } },
  virtual_lines = false,
  update_in_insert = false,
})
