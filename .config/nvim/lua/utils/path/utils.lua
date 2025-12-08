local M = {}
M.path_sep = package.config:sub(1, 1)

-- ============================================================================
-- Definir highlights estáticos una sola vez (al cargar el módulo)
-- ============================================================================
vim.api.nvim_set_hl(0, "LualineFolder", { fg = "#fab387" })
vim.api.nvim_set_hl(0, "LualineSeparator", { fg = "#585b70" })
vim.api.nvim_set_hl(0, "LualineFileName", { fg = "#ffffff" })

-- ============================================================================
-- Helpers usando mini.icons (que ya tiene sus propios highlights)
-- ============================================================================
function M.get_icon()
  local ok, mini_icons = pcall(require, "mini.icons")
  if not ok then return " ", "MiniIconsGrey" end

  -- mini.icons ya retorna el ícono y el highlight group
  local icon, hl = mini_icons.get("file", vim.fn.expand("%:t"))

  -- Si no encuentra, intenta por filetype
  if not icon or icon == "" then
    icon, hl = mini_icons.get("filetype", vim.bo.filetype)
  end
  return icon or " ", hl or "MiniIconsGrey"
end

-- ============================================================================
-- Componente principal de lualine (usando highlights estáticos + mini.icons)
-- ============================================================================
M.filename = {
  function(self)
    local fullpath = vim.fn.expand("%:p")

    -- Casos especiales
    if fullpath == "" or vim.bo.buftype ~= "" then
      return "[No Name]"
    end

    if vim.fn.isdirectory(fullpath) == 1 then
      return vim.fn.fnamemodify(fullpath, ":t")
    end

    -- Extraer información del archivo
    local filename = vim.fn.expand("%:t")
    local parent_folder = vim.fn.fnamemodify(fullpath, ":h:t")

    -- Construir el resultado usando highlights estáticos
    local result = ""
    local folder_icon = " " -- o " ", " ", "󰊢 "

    -- Folder (estático)
    result = result .. folder_icon .. "%#LualineFolder#" .. parent_folder .. "%*"

    -- Separador (estático) - AQUÍ está la corrección
    result = result .. "%#LualineSeparator#  %*" -- slash
    -- Ícono del archivo (usa highlights de mini.icons que ya existen)
    local file_icon, icon_hl = M.get_icon()
    result = result .. "%#" .. icon_hl .. "#" .. file_icon .. " %*"

    -- Nombre del archivo (estático)
    result = result .. "%#LualineFileName#" .. filename .. "%*"

    return result
  end,
  padding = { left = 1, right = 1 },
}

return M
