-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================
now_if_args(function()
  add({ source = "nvim-treesitter/nvim-treesitter" })
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua",
      "go",
    },
    indent = {
      enable = true,
    },
    highlight = {
      enable = true,
      disable = function(_, buf)
        local max_filesize = 50 * 1024 -- 50 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
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

        require("path.utils").filename,
        {
          function()
            local bc = require("breadcrumbs").get()
            if bc == "" then return "" end
            return "%#Crumb#" .. bc .. "%*"
          end,
          cond = function() return require("breadcrumbs").get() ~= "" end,
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

-- MiniDeps.now(function()
--   add("bjarneo/pixel.nvim")
--   require("pixel").setup({
--     -- vim.cmd.colorscheme("pixel")
--   })
--   vim.cmd [[
--     highlight Normal guibg=none
--     highlight NonText guibg=none
--     highlight Normal ctermbg=none
--     highlight NonText ctermbg=none
--     highlight Insert ctermbg=none
--   ]]
--   vim.api.nvim_set_hl(0, "CursorLine", { guibg = NONE, cterm = underline })
--   vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
--   vim.api.nvim_set_hl(0, 'Visual', { reverse = true })
--   vim.api.nvim_set_hl(0, 'VisualNOS', { reverse = true })
-- end)
-- Kanagawa ===============================================================================
MiniDeps.now(function()
  add("rebelot/kanagawa.nvim")
  require('kanagawa').setup({
    transparent = true,
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
  vim.cmd("colorscheme solarized-osaka")
end)

MiniDeps.now(function()
  -- vim.cmd('colorscheme miniwinter')
end)
