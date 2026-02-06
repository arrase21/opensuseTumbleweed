local M = {}

function M.get()
  local ft = vim.bo.filetype or ""
  if type(ft) == "table" then
    ft = ft[1] or ""
  end

  local handlers = {
    go              = "go",
    python          = "python",
    lua             = "lua",
    typescript      = "ts",
    typescriptreact = "ts",
    javascript      = "ts",
    javascriptreact = "ts",
  }

  local handler = handlers[ft]
  if handler then
    return require("utils.breadcrumbs." .. handler).get()
  end

  return ""
end

return M
