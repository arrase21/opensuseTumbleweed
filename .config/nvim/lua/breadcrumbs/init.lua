local M = {}

function M.get()
  local ft = vim.bo.filetype

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
    return require("breadcrumbs." .. handler).get()
  end

  return ""
end

return M
