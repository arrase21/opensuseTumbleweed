local M = {}

local function ic(char, hl)
  return string.format("%%#%s#%s%%*", hl, char) .. " "
end

local icons = {
  class  = ic("󰠱", "Type"),
  func   = ic("󰊕", "Function"),
  method = ic("󰊕", "Function"),
  var    = ic("󰀫", "Identifier"),
}

local function text(node, bufnr)
  if not node then return nil end
  local ok, res = pcall(vim.treesitter.get_node_text, node, bufnr or 0)
  return ok and res or nil
end

function M.get()
  local bufnr = vim.api.nvim_get_current_buf()

  local ok = pcall(vim.treesitter.get_parser, bufnr, vim.bo.filetype)
  if not ok then return "" end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
  if not node then return "" end

  local parts = {}
  local current = node

  while current do
    local tp = current:type()

    -- class Foo {}
    if tp == "class_declaration" then
      local name = current:field("name")[1]
      if name then
        table.insert(parts, 1, icons.class .. text(name, bufnr))
      end
    end

    -- function foo()
    if tp == "function_declaration" then
      local name = current:field("name")[1]
      if name then
        table.insert(parts, 1, icons.func .. text(name, bufnr))
      end
    end

    -- foo() inside class
    if tp == "method_definition" then
      local name = current:field("property_identifier")[1]
      if name then
        table.insert(parts, 1, icons.method .. text(name, bufnr))
      end
    end

    -- const x =
    if tp == "lexical_declaration" then
      local names = current:field("declarator")[1]
      if names then
        table.insert(parts, 1, icons.var .. text(names, bufnr))
      end
    end

    current = current:parent()
  end

  return table.concat(parts, " ")
end

return M
