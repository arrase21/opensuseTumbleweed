-- Themes ==========================================================

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
--
-- Tokyo Night =========================================================================
require("tokyonight").setup({ transparent = false })
-- vim.cmd("colorscheme tokyonight")

-- Solarized ===========================================================================
-- require("solarized-osaka").setup({ transparent = true })
-- vim.cmd("colorscheme solarized-osaka")

--Gruvbox =================================================================
require("gruvbox").setup({
  enable = {
    lualine = true,
  },

  styles = {
    bold = true,
    italic = true,
    transparency = true,
  },

})
