local M = {}
M.path_sep = package.config:sub(1, 1)

-- Highlight cacheado
function M.lualine_format_hl(component, text, hl_group)
  if not hl_group or hl_group == "" or text == "" then return text end
  component.hl_cache = component.hl_cache or {}
  local cached = component.hl_cache[hl_group]
  if not cached then
    local u = require("lualine.utils.utils")
    local gui = vim.tbl_filter(function(x) return x end, {
      u.extract_highlight_colors(hl_group, "bold") and "bold",
      u.extract_highlight_colors(hl_group, "italic") and "italic",
    })
    cached = component:create_hl({
      fg = u.extract_highlight_colors(hl_group, "fg"),
      gui = #gui > 0 and table.concat(gui, ",") or nil,
    }, hl_group)
    component.hl_cache[hl_group] = cached
  end
  return component:format_hl(cached) .. text .. component:get_default_hl()
end

function M.get_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then return " ", nil end
  local filename = vim.fn.expand("%:t")
  local icon, hl = devicons.get_icon(filename)
  if not icon then icon, hl = devicons.get_icon_by_filetype(vim.bo.filetype) end
  return icon or " ", hl
end

M.filename = {
  function(self)
    local fullpath = vim.fn.expand("%:p")
    if fullpath == "" or vim.bo.buftype ~= "" then return "[No Name]" end
    if vim.fn.isdirectory(fullpath) == 1 then return vim.fn.fnamemodify(fullpath, ":t") end

    local filename = vim.fn.expand("%:t")
    local parent_folder = vim.fn.fnamemodify(fullpath, ":h:t")

    local result = ""

    local folder_icon = " " -- o " ", " ", "󰊢 "

    local folder_hl = self:create_hl({ fg = "#fab387" }, "Folder")
    result = result .. folder_icon
    result = result .. self:format_hl(folder_hl) .. parent_folder .. self:get_default_hl()

    local sep_hl = self:create_hl({ fg = "#585b70" }, "Separator") -- gris sutil
    result = result .. self:format_hl(sep_hl) .. "  " .. self:get_default_hl()

    local file_icon, file_icon_hl = M.get_icon()
    if file_icon_hl then
      result = result .. M.lualine_format_hl(self, file_icon .. " ", file_icon_hl)
    else
      result = result .. file_icon .. " "
    end

    local name_hl = self:create_hl({ fg = "#ffffff" }, "FileName")
    result = result .. self:format_hl(name_hl) .. filename .. self:get_default_hl()

    return result
  end,
  padding = { left = 1, right = 1 },
}

return M
