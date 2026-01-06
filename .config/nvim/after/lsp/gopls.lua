return {
  cmd = { "/home/arrase/go/bin/gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  servers = {
    gopls = {
      settings = {
        gopls = {
          gofumpt = true,
          codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            rangevariableTypes = true,
            parameterNames = true,
            constantValues = true,
            assingVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            functionTypeParameters = true,
          },
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
          },
          usePlaceholders = true,
          completeUnimported = true,
          staticcheck = true,
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
          semanticTokens = true,
        },
      },
    },
  }
}

-- return {
--   cmd = { "/home/arrase/go/bin/gopls" },
--   filetypes = { "go", "gomod", "gowork", "gotmpl" },
--   root_markers = { "go.work", "go.mod", ".git" },
--   on_attach = function(client, bufnr)
--     -- Deshabilita semánticas tokens al inicio (puedes habilitarlo después)
--     client.server_capabilities.semanticTokensProvider = nil
--   end,
--   servers = {
--     gopls = {
--       settings = {
--         gopls = {
--           gofumpt = true,
--           -- Deshabilita análisis pesados al inicio
--           analyses = {
--             nilness = false,      -- Cambiar a false
--             unusedparams = false, -- Cambiar a false
--             unusedwrite = false,  -- Cambiar a false
--             useany = false,       -- Cambiar a false
--           },
--           codelenses = {
--             gc_details = false,
--             generate = false,           -- Cambiar a false
--             regenerate_cgo = false,     -- Cambiar a false
--             run_govulncheck = false,    -- Esto es pesado, cambiar a false
--             test = false,               -- Cambiar a false
--             tidy = false,               -- Cambiar a false
--             upgrade_dependency = false, -- Cambiar a false
--             vendor = false,             -- Cambiar a false
--           },
--           hints = {
--             rangevariableTypes = true,
--             parameterNames = true,
--             constantValues = true,
--             assingVariableTypes = true,
--             compositeLiteralFields = true,
--             compositeLiteralTypes = true,
--             functionTypeParameters = true,
--           },
--           usePlaceholders = true,
--           completeUnimported = true,
--           staticcheck = false,    -- Cambiar a false, es MUY pesado
--           directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
--           semanticTokens = false, -- Cambiar a false
--           -- Añade estas opciones de rendimiento
--           ["build.buildFlags"] = { "-tags=integration" },
--           env = {
--             GOFLAGS = "-tags=integration",
--           },
--         },
--       },
--     },
--   }
-- }
