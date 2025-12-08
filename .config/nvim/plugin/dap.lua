-- ┌─────────────────────────┐
-- │ Plugins for DAP         │
-- └─────────────────────────┘
--
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

later(function()
  MiniDeps.add({
    source = "mfussenegger/nvim-dap",
    depends = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "nvim-neotest/nvim-nio",
    },
  })

  local dap, dapui = require("dap"), require("dapui")
  require("dapui").setup()
  require("dap-go").setup()

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end

  local keys = {
    { "<leader>db", dap.toggle_breakpoint,                                                                     desc = "Toggle Breakpoint" },
    { "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end,                            desc = "Conditional Breakpoint" },
    { "<leader>dc", dap.continue,                                                                              desc = "Continue / Start" },
    { "<leader>dC", dap.run_to_cursor,                                                                         desc = "Run to Cursor" },
    { "<leader>di", dap.step_into,                                                                             desc = "Step Into" },
    { "<leader>do", dap.step_out,                                                                              desc = "Step Out" },
    { "<leader>dO", dap.step_over,                                                                             desc = "Step Over" },
    { "<leader>dl", dap.run_last,                                                                              desc = "Run Last" },
    { "<leader>dt", dap.terminate,                                                                             desc = "Terminate" },
    { "<leader>dr", dap.repl.toggle,                                                                           desc = "Toggle REPL" },
    { "<leader>du", dapui.toggle,                                                                              desc = "Toggle DAP UI" },
    { "<leader>dh", function() require("dap.ui.widgets").hover() end,                                          desc = "Hover" },
    { "<leader>dp", function() require("dap.ui.widgets").preview() end,                                        desc = "Preview" },
    { "<leader>df", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames) end, desc = "Frames" },
    { "<leader>ds", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes) end, desc = "Scopes" },
  }

  for _, key in ipairs(keys) do
    vim.keymap.set("n", key[1], key[2], { desc = "DAP: " .. key.desc })
  end

  -- Opcional: iconos bonitos si usas algún plugin como nvim-web-devicons
  vim.fn.sign_define("DapBreakpoint", { text = "󰃤 ", texthl = "DapBreakpoint", linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition",
    { text = "󱌢 ", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "", numhl = "" })
end)
