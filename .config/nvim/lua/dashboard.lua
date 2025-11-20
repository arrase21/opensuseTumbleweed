-- ~/.config/nvim/lua/dashboard.lua
local M = {}

local header = {
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  [[                                                                       ]],
}

local get_icon = require("mini.icons").get

local buttons = {
  { "dracula", "Find File",       "f", function() require("mini.pick").builtin.files() end },
  { "config",  "Restore Session", "s", function() vim.cmd("SessionLoad") end },
  { "change",  "Quit Neovim",     "q", function() vim.cmd("qa") end },
  { "tads", "Clear Recent Files", "c", function()
    local shada = vim.fn.stdpath("state") .. "/shada/main.shada"
    os.remove(shada)
    vim.v.oldfiles = {}
    vim.cmd("enew")
    require("dashboard").show()
  end },
}


local function center(str)
  local width = vim.api.nvim_win_get_width(0)
  local len = vim.fn.strdisplaywidth(str)
  return string.rep(" ", math.max(0, math.floor((width - len) / 2))) .. str
end

function M.show()
  local buf = vim.api.nvim_get_current_buf()
  -- vim.api.nvim_buf_set_name(buf, "NeovimDashboard")
  vim.api.nvim_buf_set_name(buf, "Neovim")
  vim.api.nvim_set_current_buf(buf)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.cursorline = false -- opcional, queda más limpio
  vim.opt_local.colorcolumn = ""
  vim.bo[buf].modifiable = true
  vim.defer_fn(function()
    local row = #header + 3
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    vim.cmd("normal! ^")
  end, 1)

  local lines = {}
  local highlights = {}

  -- Header ===========================================================================================
  for _, line in ipairs(header) do table.insert(lines, center(line)) end
  table.insert(lines, ""); table.insert(lines, "")

  -- Botones con iconos reales ========================================================================
  local button_rows = {}
  for _, btn in ipairs(buttons) do
    local icon, hl = get_icon("filetype", btn[1])
    local text = icon .. "  " .. btn[2] .. string.rep(" ", 75 - vim.fn.strdisplaywidth(btn[2])) .. " [" .. btn[3] .. "]"
    table.insert(lines, center(text))

    local row = #lines - 1
    table.insert(button_rows, { row = row, action = btn[4] })
    local col = math.floor((vim.api.nvim_win_get_width(0) - vim.fn.strdisplaywidth(text)) / 2)

    -- Highlights =========================================================================================
    table.insert(highlights, { hl or "DashboardIcon", row, col, col + vim.fn.strdisplaywidth(icon) + 2 })
    table.insert(highlights,
      { "DashboardDesc", row, col + vim.fn.strdisplaywidth(icon) + 2, col + vim.fn.strdisplaywidth(icon) + 2 +
      vim.fn.strdisplaywidth(btn[2]) })
    table.insert(highlights, { "DashboardKey", row, col + vim.fn.strdisplaywidth(text) - 3, -1 })
    vim.keymap.set("n", btn[3], btn[4], { buffer = buf, silent = true })
  end

  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- fila actual (0-indexed)

      for _, btn in ipairs(button_rows) do
        if btn.row == current_row then
          btn.action()
          break
        end
      end
    end,
    silent = true,
    nowait = true,
  })
  table.insert(lines, ""); table.insert(lines, center("Recent Files")); table.insert(lines, "")

  -- Recent files ===========================================================================================================
  local recent = {}
  for _, f in ipairs(vim.v.oldfiles) do
    if #recent >= 10 then break end
    if vim.fn.filereadable(f) == 1 and not f:find("COMMIT_EDITMSG") then
      table.insert(recent, f)
    end
  end

  local recent_rows = {}
  for i, file in ipairs(recent) do
    local icon, hl = get_icon("file", file)
    local name     = vim.fn.fnamemodify(file, ":t")
    local dir      = vim.fn.fnamemodify(file, ":p:h:~"):gsub("/[^/]+$", "/")
    local short    = dir .. name
    if vim.fn.strdisplaywidth(short) > 60 then
      short = "…" .. string.sub(short, -59)
    end

    local line = "  " .. icon .. "  " .. short
    local num = i == 10 and "0" or tostring(i)
    local full_line = line .. string.rep(" ", 85 - vim.fn.strdisplaywidth(line)) .. num

    table.insert(lines, center(full_line))

    local row = #lines - 1
    table.insert(recent_rows, { row = row, file = file })
    local col = math.floor((vim.api.nvim_win_get_width(0) - vim.fn.strdisplaywidth(full_line)) / 2)

    table.insert(highlights, { hl, row, col + 2, col + 2 + vim.fn.strdisplaywidth(icon) })
    table.insert(highlights,
      { "DashboardDesc", row, col + vim.fn.strdisplaywidth(icon) + 4, col + vim.fn.strdisplaywidth(line) + 2 })
    table.insert(highlights, { "DashboardKey", row, col + vim.fn.strdisplaywidth(full_line) - 2, -1 })

    vim.keymap.set("n", num, function() vim.cmd("edit " .. vim.fn.fnameescape(file)) end,
      { buffer = buf, silent = true })
  end
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1

      for _, btn in ipairs(button_rows) do
        if btn.row == current_row then
          btn.action()
          return
        end
      end

      for _, rec in ipairs(recent_rows) do
        if rec.row == current_row then
          vim.cmd("edit " .. vim.fn.fnameescape(rec.file))
          return
        end
      end
    end,
    silent = true,
    nowait = true,
  })

  -- Footter ==========================================================================
  local ms = "?.??"
  if vim.uv then
    local now = vim.uv.hrtime()
    ms = string.format("%.2f", (now - (vim.g.nvim_start_time or now)) / 1e6)
  end
  table.insert(lines, "")
  table.insert(lines, center("Neovim started in " .. ms .. "ms"))

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, h[1], h[2], h[3], h[4])
  end

  vim.bo[buf].modifiable = false

  vim.defer_fn(function()
    local row = #header + 3
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    vim.cmd("normal! ^")
    vim.cmd("normal! 3l")
  end, 10)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc(-1) > 0 then return end
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" and vim.uv.fs_stat(bufname) then return end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines > 1 or (lines[1] and lines[1]:match("%S")) then return end
    if vim.g.started_by_firenvim or vim.bo.filetype == "oil" then return end
    M.show()
  end,
  group = vim.api.nvim_create_augroup("CustomDashboard", { clear = true }),
})

-- Colors  ==========================================================================
vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#89b4fa", bold = true })
vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#cdd6f4" })
vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#a6e3a1", bold = true })
return M
