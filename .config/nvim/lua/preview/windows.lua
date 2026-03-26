local M = {}

---@type number | nil
M.preview_win = nil
---@type number | nil
M.preview_buf = nil

---@return number
local function create_preview_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  return buf
end

---@return number | nil
function M.open()
  M.close()
  M.preview_buf = create_preview_buffer()

  local picker_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(picker_win) then return nil end

  local cfg = vim.api.nvim_win_get_config(picker_win)
  if not cfg.relative or cfg.relative == "" then return nil end

  local half_width = math.floor((vim.o.columns - 6) / 2)

  pcall(vim.api.nvim_win_set_config, picker_win, {
    relative = cfg.relative,
    anchor   = cfg.anchor,
    row      = cfg.row,
    col      = cfg.col,
    width    = half_width,
    height   = cfg.height,
  })

  local preview_col = cfg.col + half_width + 4

  local preview_config = {
    relative  = "editor",
    focusable = false,
    style     = "minimal",
    border    = cfg.border,
    noautocmd = cfg.noautocmd,
    anchor    = cfg.anchor,
    zindex    = cfg.zindex and (cfg.zindex - 1),
    height    = cfg.height,
    row       = cfg.row,
    col       = preview_col,
    width     = half_width,
  }

  pcall(function()
    M.preview_win = vim.api.nvim_open_win(M.preview_buf, false, preview_config)
  end)

  if M.preview_win and vim.api.nvim_win_is_valid(M.preview_win) then
    pcall(function()
      vim.api.nvim_set_hl(0, "MiniPickPreviewNormal", { link = "MiniPickNormal" })
      vim.api.nvim_set_hl(0, "MiniPickPreviewBorder", { link = "MiniPickBorder" })
      vim.api.nvim_win_set_config(M.preview_win, {
        winhighlight = "Normal:MiniPickPreviewNormal,FloatBorder:MiniPickPreviewBorder",
      })
      -- Habilitar scroll con el mouse sobre la ventana de preview
      vim.wo[M.preview_win].scrolloff = 0
      vim.api.nvim_win_call(M.preview_win, function()
        vim.opt_local.mouse = "a"
      end)
    end)
  end

  return M.preview_win
end

---@param lines number positivo = scroll abajo, negativo = scroll arriba
function M.scroll(lines)
  if not M.is_open() then return end
  vim.api.nvim_win_call(M.preview_win, function()
    local key = lines > 0 and "\x05" or "\x19" -- <C-e> / <C-y>
    vim.cmd("normal! " .. math.abs(lines) .. (lines > 0 and "\x05" or "\x19"))
  end)
end

function M.close()
  if M.preview_win and vim.api.nvim_win_is_valid(M.preview_win) then
    vim.api.nvim_win_close(M.preview_win, true)
    M.preview_win = nil
  end
  if M.preview_buf and vim.api.nvim_buf_is_valid(M.preview_buf) then
    vim.api.nvim_buf_delete(M.preview_buf, { force = true })
    M.preview_buf = nil
  end
end

---@return boolean
function M.is_open()
  return M.preview_win ~= nil and vim.api.nvim_win_is_valid(M.preview_win)
end

---@return number | nil
function M.get_preview_buf()
  return M.preview_buf
end

return M
