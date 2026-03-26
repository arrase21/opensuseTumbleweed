local M = {}
local window = require("preview.windows")
local current_timer = nil
local last_item = nil

local function update_preview(item)
  if not window.is_open() or not item or item == "" then return end
  local preview_buf = window.get_preview_buf()
  if not (preview_buf and vim.api.nvim_buf_is_valid(preview_buf)) then return end

  pcall(function()
    local opts = MiniPick.get_picker_opts()
    local picker_name = (opts and opts.source and opts.source.name) or ""

    -- Limpiar buffer completamente
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})

    local out = {}
    local ft = "text"

    if picker_name == 'Git Status' then
      local path = item:sub(4):gsub('^%s+', ''):gsub('%s+$', ''):gsub('^"', ''):gsub('"$', '')
      out = vim.fn.systemlist({ 'git', 'diff', 'HEAD', '--', path })
      if #out == 0 and vim.fn.filereadable(path) == 1 then
        out = vim.fn.systemlist({ 'cat', path })
      end
      ft = "diff"
    elseif picker_name == 'Git Log' or picker_name == 'Git Checkout Commit' then
      local hash = item:match('^%s*(%x%x%x%x%x%x%x)')
      if hash then
        out = vim.fn.systemlist({ 'git', 'show', '--stat', '--patch', '--format=%B', hash })
        ft = "git"
      end
    elseif picker_name == 'Git Branches' then
      local branch = item:gsub('^[*%s]+', '')
      out = vim.fn.systemlist({ 'git', 'log', '-1', '--stat', branch })
      ft = "git"
    else
      -- CASO FILES: Carga manual para evitar conflictos de mappings
      -- Si es un archivo físico, lo leemos
      if vim.fn.filereadable(item) == 1 then
        out = vim.fn.readfile(item, "", 100)
        ft = vim.filetype.match({ filename = item }) or "text"
      else
        -- Si no es legible (ej. un directorio o string raro), solo ponemos el nombre
        out = { item }
        ft = "text"
      end
    end

    -- Aplicar contenido
    if out and #out > 0 then
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, out)
      vim.api.nvim_buf_set_option(preview_buf, "filetype", ft)
    end

    vim.cmd("redraw")
  end)
end

local function on_timer_tick()
  vim.schedule(function()
    local ok, matches = pcall(MiniPick.get_picker_matches)
    if not ok or not matches or not matches.current then return end
    local item = matches.current
    if item ~= last_item then
      last_item = item
      update_preview(item)
    end
  end)
end

local function on_pick_start()
  window.open()
  last_item = nil
  current_timer = vim.uv.new_timer()
  current_timer:start(10, 10, on_timer_tick)
end

local function on_pick_stop()
  if current_timer then
    current_timer:stop()
    current_timer:close()
    current_timer = nil
  end
  last_item = nil
  window.close()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("MiniPickPreview", { clear = true })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "MiniPickStart", callback = on_pick_start })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "MiniPickStop", callback = on_pick_stop })
end

return M
