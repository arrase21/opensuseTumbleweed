-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘

local add = vim.pack.add
local now, later = Config.now_if_args, Config.later

add({ 'https://github.com/nvim-treesitter/nvim-treesitter', })

-- ┌─────────────────────────┐
-- │        Themes           │
-- └─────────────────────────┘

-- Themes =============================================================================================
add({ "https://github.com/rebelot/kanagawa.nvim", })
require('kanagawa').setup({
  transparent = true,
  compile = false,

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
      NormalFloat  = { bg = "none" },
      FloatBorder  = { bg = "none" },
      FloatTitle   = { bg = "none" },
      StatusLine   = { bg = theme.ui.bg_p1 },
      StatusLineNC = { bg = theme.ui.bg_m1 },
    }
  end,
})
-- vim.cmd("colorscheme kanagawa-wave")
-- GruvBox ==============================================================
add { "https://gitlab.com/motaz-shokry/gruvbox.nvim" }
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
-- vim.cmd('colorscheme gruvbox')

-- Solarized ============================================================
add { "https://github.com/craftzdog/solarized-osaka.nvim" }
require("solarized-osaka").setup({ transparent = true })
-- vim.cmd("colorscheme solarized-osaka")

-- TokyoNight ===========================================================
add({ "https://github.com/folke/tokyonight.nvim" })
require("tokyonight").setup({
  transparent = false,
})
-- vim.cmd('colorscheme tokyonight')


--dracula ===============================================================
add({ "https://github.com/arrase21/dracula.nvim" })
require("dracula").setup({
  transparent_bg = true
})
vim.cmd('colorscheme dracula')

-- ┌─────────────────────────┐
-- │           DAP           │
-- └─────────────────────────┘

-- Dap ==================================================================

later(function()
  add({
    "https://github.com/mfussenegger/nvim-dap",
    { src = "https://github.com/mfussenegger/nvim-dap-python" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/leoluz/nvim-dap-go" },
    { src = "https://github.com/nvim-neotest/nvim-nio" }
  })

  local dap, dapui = require("dap"), require("dapui")
  local widgets = require("dap.ui.widgets")

  dapui.setup()
  require("dap-go").setup()
  require("dap-python").setup("~/.local/share/uv/tools/debugpy/bin/python")

  dap.listeners.before.attach.dapui_config = function() dapui.open() end
  dap.listeners.before.launch.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

  local d_map = {
    b = { dap.toggle_breakpoint, "Toggle Breakpoint" },
    B = { function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional Breakpoint" },
    c = { dap.continue, "Continue / Start" },
    C = { dap.run_to_cursor, "Run to Cursor" },
    i = { dap.step_into, "Step Into" },
    o = { dap.step_out, "Step Out" },
    O = { dap.step_over, "Step Over" },
    l = { dap.run_last, "Run Last" },
    t = { dap.terminate, "Terminate" },
    r = { dap.repl.toggle, "Toggle REPL" },
    u = { dapui.toggle, "Toggle DAP UI" },
    h = { widgets.hover, "Hover" },
    p = { widgets.preview, "Preview" },
    f = { function() widgets.centered_float(widgets.frames) end, "Frames" },
    s = { function() widgets.centered_float(widgets.scopes) end, "Scopes" },
  }

  for suffix, conf in pairs(d_map) do
    vim.keymap.set("n", "<leader>d" .. suffix, conf[1], { desc = "DAP: " .. conf[2] })
  end
  -- Iconos de los signos
  vim.fn.sign_define("DapBreakpoint", { text = "󰃤 ", texthl = "DapBreakpoint" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "󱌢 ", texthl = "DapBreakpointCondition" })
  vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped" })
end)

-- Kulala =========================================================================================================================================
later(function()
  add({ "https://github.com/mistweaverco/kulala.nvim" })
  require("kulala").setup()
  vim.api.nvim_set_hl(0, "MiniCursorword", { link = "Visual" })
end)
