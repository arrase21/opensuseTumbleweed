local M = {}

-- Helpers
local function ic(char, hl)
  return string.format("%%#%s#%s%%*", hl, char) .. " " -- El espacio ya está fuera con %%*
end
local icons = {
  struct    = ic("󰆼", "Type"),
  database  = ic("󰆼", "Type"),
  method    = ic("󰊕", "Function"),
  func      = ic("󰡱", "Function"),
  field     = ic("󰜢", "Identifier"),
  var       = ic("󰀫", "Identifier"),
  string    = ic("󰜢", "Type"),
  number    = ic("󰎠", "Number"),
  bool      = ic("◩", "Boolean"),
  array     = ic("󰅪", "Type"),
  map       = ic("󰘨", "Type"),
  interface = ic("󰜰 ", "Interface"),
  pointer   = ic("󰜢", "Type"),
  custom    = ic(" ", "Custom"),
}

local TYPE_NODES = {
  type_identifier = true,
  qualified_type = true,
  slice_type = true,
  array_type = true,
  map_type = true,
  pointer_type = true,
  interface_type = true,
}

local function is_type_node(t)
  return TYPE_NODES[t] == true
end

local function get_node_text(node, bufnr)
  if not node then return nil end
  local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr or 0)
  return ok and text or nil
end

-- Type → Icon resolver
local function get_type_icon(type_text)
  if not type_text then return icons.custom end

  if type_text:match("^string") then
    return icons.string
  end
  if type_text:match("^[iu]?int") or type_text:match("^float") or type_text:match("^byte") then
    return icons.number
  end
  if type_text:match("^bool") then
    return icons.bool
  end
  if type_text:match("^%[%]") then
    return icons.array
  end
  if type_text:match("^map%[") then
    return icons.map
  end
  if type_text:match("^interface") then
    return icons.interface
  end
  if type_text:match("^%*") then
    return icons.pointer
  end

  return icons.custom
end

-- Main breadcrumb generator
-- ------------------------------
function M.get()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = vim.bo.filetype

  -- Treesitter parser check (barato)
  if not pcall(vim.treesitter.get_parser, bufnr, lang) then
    return ""
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
  if not node then return "" end

  local breadcrumbs = {}
  local struct_name, field_name, field_type = nil, nil, nil

  -- PRE-CACHE LINE MATCHING
  -- ------------------------------
  local function extract_field_from_declaration(parent)
    for child in parent:iter_children() do
      local t = child:type()
      if t == "field_identifier" and not field_name then
        field_name = get_node_text(child, bufnr)
      elseif is_type_node(t) and not field_type then
        field_type = get_node_text(child, bufnr)
      end
      if field_name and field_type then break end
    end
  end

  -- MAIN UPWARD WALK
  -- ------------------------------
  local current = node
  while current do
    local node_type = current:type()

    -- Rápido: detectar struct
    if node_type == "type_spec" and not struct_name then
      local name = current:field("name")[1]
      struct_name = name and get_node_text(name, bufnr)
    end

    -- Campo dentro de struct
    if node_type == "field_declaration" and not field_name then
      extract_field_from_declaration(current)
    end

    -- field_identifier → buscar tipo rápido en parent
    if node_type == "field_identifier" and not field_name then
      field_name = get_node_text(current, bufnr)

      local parent = current:parent()
      if parent and parent:type() == "field_declaration" then
        extract_field_from_declaration(parent)
      end
    end

    -- Si está dentro de field_declaration_list, ubicar campo correcto por rango
    if node_type == "field_declaration_list" and not field_name then
      for child in current:iter_children() do
        if child:type() == "field_declaration" then
          local srow, _, erow = child:range()
          if row >= srow and row <= erow then
            extract_field_from_declaration(child)
            break
          end
        end
      end
    end

    -- Método
    if node_type == "method_declaration" then
      local name = current:field("name")[1]
      name = name and get_node_text(name, bufnr)
      if name then table.insert(breadcrumbs, 1, icons.method .. name) end
    end

    -- Función
    if node_type == "function_declaration" then
      local name = current:field("name")[1]
      name = name and get_node_text(name, bufnr)
      if name then table.insert(breadcrumbs, 1, icons.func .. name) end
    end

    -- Variables cortas: rápida extracción
    if node_type == "short_var_declaration" then
      local added = false
      for child in current:iter_children() do
        local t = child:type()
        if t == "identifier" and not added then
          local name = get_node_text(child, bufnr)
          if name then table.insert(breadcrumbs, 1, icons.var .. name) end
          added = true
        elseif t == "expression_list" and not added then
          for expr in child:iter_children() do
            if expr:type() == "identifier" then
              local name = get_node_text(expr, bufnr)
              if name then table.insert(breadcrumbs, 1, icons.var .. name) end
              added = true
              break
            end
          end
        end
        if added then break end
      end
    end

    current = current:parent()
  end

  -- BUILD OUTPUT
  local result = {}

  for _, bc in ipairs(breadcrumbs) do
    table.insert(result, bc)
  end

  if struct_name then
    table.insert(result, icons.struct .. struct_name)
  end
  if field_name then
    table.insert(result, get_type_icon(field_type) .. field_name)
  end

  return #result > 0 and table.concat(result, " ") or ""
end

return M
