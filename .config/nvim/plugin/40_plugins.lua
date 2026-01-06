-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================
-- now_if_args(function()
--   add({ source = "nvim-treesitter/nvim-treesitter" })
--   require("nvim-treesitter.configs").setup({
--     ensure_installed = {
--       "lua",
--       "go",
--       "python",
--     },
--     indent = {
--       enable = true,
--     },
--     highlight = {
--       enable = true,
--       disable = function(_, buf)
--         local max_filesize = 50 * 1024 -- 50 KB
--         local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--         if ok and stats and stats.size > max_filesize then
--           return true
--         end
--       end,
--     },
--     auto_install = true,
--   })
-- end)


now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  -- Define languages which will have parsers installed and auto enabled
  local languages = {
    'lua',
    'vimdoc',
    'go',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  _G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')

  require("nvim-treesitter.configs").setup({
    indent = {
      enable = true,
    },
    highlight = {
      enable = true,
    },
    auto_install = true,
  })
end)
-- Formatting =================================================================

-- formatting setup.
-- later(function()
--   add('stevearc/conform.nvim')
--
--   require('conform').setup({
--   })
-- end)

-- Mason =======================================================================

-- later(function()
--   add('mason-org/mason.nvim')
--   require('mason').setup()
-- end)

-- Lualine =============================================================================
MiniDeps.now(function()
  add("nvim-lualine/lualine.nvim")
  require("lualine").setup({
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },

      lualine_c = {
        {
          "diagnostics",
          symbols = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },

        require("utils.path.utils").filename,
        {
          function()
            local bc = require("utils.breadcrumbs").get()
            if bc == "" then return "" end
            return "%#Crumb#" .. bc .. "%*"
          end,
          cond = function() return require("utils.breadcrumbs").get() ~= "" end,
          padding = { left = 1, right = 0 },
        },
      },

      lualine_x = {
        {
          "lsp_status",
        },
      },
      lualine_y = { "progress", "location" },
      lualine_z = {
        function() return " " .. os.date("%R") end,
      },
    },
  })
end)

-- Themes ======================================================================

-- Kanagawa ===============================================================================
MiniDeps.now(function()
  add("rebelot/kanagawa.nvim")
  require('kanagawa').setup({
    transparent = true,
    compile = false,
    undercurl = true,
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle = {},

    colors = {
      palette = {},
      theme = {
        all = {
          ui = {
            float = {
              bg = "none",
            },
            bg_gutter = "none",
          }
        }
      }
    },

    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },

        DiagnosticVirtualTextError = { bg = "none" },
        DiagnosticVirtualTextWarn = { bg = "none" },
        DiagnosticVirtualTextInfo = { bg = "none" },
        DiagnosticVirtualTextHint = { bg = "none" },

        -- Simplificar completion menu
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },
      }
    end,

    theme = "wave", -- o "dragon", "lotus"
    background = {
      dark = "wave",
      light = "lotus"
    },
  })

  -- vim.cmd("colorscheme kanagawa-wave")
end)
-- Tokyo Night =========================================================================
MiniDeps.now(function()
  add("folke/tokyonight.nvim")
  require("tokyonight").setup({ transparent = true })
  -- vim.cmd("colorscheme tokyonight")
end)

-- Solarized ===========================================================================
MiniDeps.now(function()
  add("craftzdog/solarized-osaka.nvim")
  require("solarized-osaka").setup({ transparent = true })
  -- vim.cmd("colorscheme solarized-osaka")
end)

-- miniwinter ===========================================================================
MiniDeps.now(function()
  add("ellisonleao/gruvbox.nvim")
  require("gruvbox").setup({
    transparent_mode = true,
    overrides = {
      Pmenu                      = { fg = "NONE", bg = "NONE" },
      PmenuSel                   = { fg = "NONE", bg = "#79740e" },
      PmenuSbar                  = { bg = "NONE" },
      PmenuThumb                 = { bg = "NONE" },
      DiagnosticError            = { bg = "#cc241d", fg = "#fb4934" },
      DiagnosticWarn             = { bg = "NONE", fg = "#fabd2f" },
      DiagnosticInfo             = { bg = "NONE", fg = "#83a598" },
      DiagnosticHint             = { bg = "NONE", fg = "#8ec07c" },
      -- DiagnosticLineError = { bg = "#cc241d", fg = "#1d2021" },
      DiagnosticVirtualTextError = { bg = "#cc241d", fg = "#fbf1c7" },
      -- Para errores de sintaxis
      Error                      = { bg = "#cc241d", fg = "#fbf1c7" },
      ErrorMsg                   = { bg = "#cc241d", fg = "#fbf1c7" },
    },
  })
  vim.cmd("colorscheme gruvbox")
end)

package.preload["lazy.stats"] = function()
  return {
    stats = function()
      return {
        startuptime = 0,
        count = 0,
        loaded = 0,
      }
    end,
  }
end

MiniDeps.now(function()
  add("folke/snacks.nvim")
  require("snacks").setup({
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = false
      -- layout = "vscode",
    },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    dashboard = {
      preset = {
        header = [[
   █████╗ ██████╗ ██████╗  █████╗ ███████╗███████╗██╗   ██╗██╗███╗   ███╗
  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██║   ██║██║████╗ ████║
  ███████║██████╔╝██████╔╝███████║███████╗█████╗  ██║   ██║██║██╔████╔██║
  ██╔══██║██╔══██╗██╔══██╗██╔══██║╚════██║██╔══╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║  ██║██║  ██║██║  ██║██║  ██║███████║███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  })
end)
