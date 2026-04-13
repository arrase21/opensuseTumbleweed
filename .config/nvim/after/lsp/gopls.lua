return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      hints = {
        rangevariableTypes = true,
        parameterNames = true,
        constantValues = true,
        assingVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        functionTypeParameters = true,
      },
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      -- staticcheck = false,
      -- gofumpt = false,
      -- directoryFilters = {
      --   "-.git", "-node_modules", "-vendor", "-build", "-bin", "-tmp"
      -- },
    },
  },
}
