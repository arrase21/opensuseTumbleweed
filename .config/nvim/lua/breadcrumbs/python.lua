local M = {}

local function ic(char, hl)
  return string.format("%%#%s#%s%%*", hl, char) .. " "
end

local icons = {
  class  = ic("󰠱", "Type"),
  method = ic("󰊕", "Function"),
  func   = ic("󰡱", "Function"),
  var    = ic("󰀫", "Identifier"),
  field  = ic("󰜢", "Identifier"),
}

local function text(node, bufnr)
  if not node then return nil end
  local ok, res = pcall(vim.treesitter.get_node_text, node, bufnr or 0)
  return ok and res or nil
end

function M.get()
  local bufnr = vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "python")
  if not ok then return "" end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row, col } })
  if not node then return "" end

  local parts = {}
  local current = node

  while current do
    local type = current:type()

    -- class Foo:
    if type == "class_definition" then
      local name = current:field("name")[1]
      if name then
        table.insert(parts, 1, icons.class .. text(name, bufnr))
      end
    end

    -- def foo():
    if type == "function_definition" then
      local name = current:field("name")[1]
      if name then
        table.insert(parts, 1, icons.func .. text(name, bufnr))
      end
    end

    -- variable assignment
    if type == "assignment" then
      local targets = current:field("left")
      if targets and targets[1] then
        local varname = text(targets[1], bufnr)
        if varname then
          table.insert(parts, 1, icons.var .. varname)
        end
      end
    end

    current = current:parent()
  end

  return table.concat(parts, " ")
end

return M
