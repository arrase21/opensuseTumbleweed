local M = {}

local function ic(char, hl)
  return string.format('%%#%s#%s%%* ', hl, char)
end

local TYPE_NODES = {
  type_identifier = true,
  qualified_type = true,
  slice_type = true,
  array_type = true,
  map_type = true,
  pointer_type = true,
  interface_type = true,
  time_type = true,
}

local function node_text(node, bufnr)
  if not node then return nil end
  local ok, t = pcall(vim.treesitter.get_node_text, node, bufnr or 0)
  return ok and t or nil
end

local function type_icon(t)
  if not t then return ic(' ', 'Custom') end
  if t:match('^string') then return ic('󰜢', 'Type') end
  if t:match('^[iu]?int') or t:match('^float') or
      t:match('^byte') then
    return ic('󰎠', 'Number')
  end
  if t:match('^bool') then return ic('󰄲', 'Boolean') end
  if t:match('^%[%]') then return ic('󰅪', 'Type') end
  if t:match('^map%[') then return ic('󰘨', 'Type') end
  if t:match('^interface') then return ic('󰜰', 'Interface') end
  if t:match('^%*') then return ic('󰜢', 'Type') end
  if t:match('^%time') then return ic('󰃱', 'Type') end
  return ic(' ', 'Custom')
end

function M.get()
  local bufnr = vim.api.nvim_get_current_buf()
  if not pcall(vim.treesitter.get_parser, bufnr, vim.bo.filetype) then return '' end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row - 1, col } })
  if not node then return '' end

  local crumbs = {}
  local struct_name, field_name, field_type

  local function extract_field(parent)
    for child in parent:iter_children() do
      local t = child:type()
      if t == 'field_identifier' and not field_name then
        field_name = node_text(child, bufnr)
      elseif TYPE_NODES[t] and not field_type then
        field_type = node_text(child, bufnr)
      end
      if field_name and field_type then break end
    end
  end

  local cur = node
  while cur do
    local t = cur:type()

    if t == 'type_spec' and not struct_name then
      struct_name = node_text(cur:field('name')[1], bufnr)
    elseif t == 'field_declaration' and not field_name then
      extract_field(cur)
    elseif t == 'field_identifier' and not field_name then
      field_name = node_text(cur, bufnr)
      local p = cur:parent()
      if p and p:type() == 'field_declaration' then extract_field(p) end
    elseif t == 'field_declaration_list' and not field_name then
      local r = row - 1
      for child in cur:iter_children() do
        if child:type() == 'field_declaration' then
          local sr, _, er = child:range()
          if r >= sr and r <= er then
            extract_field(child)
            break
          end
        end
      end
    elseif t == 'method_declaration' then
      local name = node_text(cur:field('name')[1], bufnr)
      if name then table.insert(crumbs, 1, ic('󰊕', 'Function') .. name) end
    elseif t == 'function_declaration' then
      local name = node_text(cur:field('name')[1], bufnr)
      if name then table.insert(crumbs, 1, ic('󰡱', 'Function') .. name) end
    elseif t == 'short_var_declaration' then
      for child in cur:iter_children() do
        local ct = child:type()
        if ct == 'identifier' then
          local name = node_text(child, bufnr)
          if name then table.insert(crumbs, 1, ic('󰀫', 'Identifier') .. name) end
          break
        elseif ct == 'expression_list' then
          for expr in child:iter_children() do
            if expr:type() == 'identifier' then
              local name = node_text(expr, bufnr)
              if name then table.insert(crumbs, 1, ic('󰀫', 'Identifier') .. name) end
              break
            end
          end
          break
        end
      end
    end

    cur = cur:parent()
  end

  if struct_name then table.insert(crumbs, ic('󰆼', 'Type') .. struct_name) end
  if field_name then table.insert(crumbs, type_icon(field_type) .. field_name) end

  return table.concat(crumbs, ' ')
end

return M
