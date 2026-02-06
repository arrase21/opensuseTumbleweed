---@brief
---
--- https://github.com/golang/tools/tree/master/gopls
---
--- Google's lsp server for golang.

--- @class go_dir_custom_args
---
--- @field envvar_id string
---
--- @field custom_subdir string?

local mod_cache = nil
local std_lib = nil

---@param custom_args go_dir_custom_args
---@param on_complete fun(dir: string | nil)
local function identify_go_dir(custom_args, on_complete)
  local cmd = { 'go', 'env', custom_args.envvar_id }
  vim.system(cmd, { text = true }, function(output)
    local res = vim.trim(output.stdout or '')
    if output.code == 0 and res ~= '' then
      if custom_args.custom_subdir and custom_args.custom_subdir ~= '' then
        res = res .. custom_args.custom_subdir
      end
      on_complete(res)
    else
      vim.schedule(function()
        vim.notify(
          ('[gopls] identify ' .. custom_args.envvar_id .. ' dir cmd failed with code %d: %s\n%s'):format(
            output.code,
            vim.inspect(cmd),
            output.stderr
          )
        )
      end)
      on_complete(nil)
    end
  end)
end

---@return string?
local function get_std_lib_dir()
  if std_lib and std_lib ~= '' then
    return std_lib
  end

  identify_go_dir({ envvar_id = 'GOROOT', custom_subdir = '/src' }, function(dir)
    if dir then
      std_lib = dir
    end
  end)
  return std_lib
end

---@return string?
local function get_mod_cache_dir()
  if mod_cache and mod_cache ~= '' then
    return mod_cache
  end

  identify_go_dir({ envvar_id = 'GOMODCACHE' }, function(dir)
    if dir then
      mod_cache = dir
    end
  end)
  return mod_cache
end

---@param fname string
---@return string?
local function get_root_dir(fname)
  if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
    local clients = vim.lsp.get_clients({ name = 'gopls' })
    if #clients > 0 then
      return clients[#clients].config.root_dir
    end
  end
  if std_lib and fname:sub(1, #std_lib) == std_lib then
    local clients = vim.lsp.get_clients({ name = 'gopls' })
    if #clients > 0 then
      return clients[#clients].config.root_dir
    end
  end
  return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
end

---@type vim.lsp.Config
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    get_mod_cache_dir()
    get_std_lib_dir()
    -- see: https://github.com/neovim/nvim-lspconfig/issues/804
    on_dir(get_root_dir(fname))
  end,
}

-- ---@type vim.lsp.Config
-- return {
--   cmd = { "/home/arrase/go/bin/gopls" },
--   filetypes = { "go", "gomod", "gowork", "gotmpl" },
--   root_markers = { "go.work", "go.mod", ".git" },
--   servers = {
--     gopls = {
--       settings = {
--         gopls = {
--           gofumpt = true,
--           codelenses = {
--             gc_details = false,
--             generate = true,
--             regenerate_cgo = true,
--             run_govulncheck = true,
--             test = true,
--             tidy = true,
--             upgrade_dependency = true,
--             vendor = true,
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
--           analyses = {
--             nilness = true,
--             unusedparams = true,
--             unusedwrite = true,
--             useany = true,
--           },
--           usePlaceholders = true,
--           completeUnimported = true,
--           staticcheck = true,
--           directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
--           semanticTokens = true,
--         },
--       },
--     },
--   }
-- }
--
-- -- return {
-- --   cmd = { "/home/arrase/go/bin/gopls" },
-- --   filetypes = { "go", "gomod", "gowork", "gotmpl" },
-- --   root_markers = { "go.work", "go.mod", ".git" },
-- --   on_attach = function(client, bufnr)
-- --     -- Deshabilita semánticas tokens al inicio (puedes habilitarlo después)
-- --     client.server_capabilities.semanticTokensProvider = nil
-- --   end,
-- --   servers = {
-- --     gopls = {
-- --       settings = {
-- --         gopls = {
-- --           gofumpt = true,
-- --           -- Deshabilita análisis pesados al inicio
-- --           analyses = {
-- --             nilness = false,      -- Cambiar a false
-- --             unusedparams = false, -- Cambiar a false
-- --             unusedwrite = false,  -- Cambiar a false
-- --             useany = false,       -- Cambiar a false
-- --           },
-- --           codelenses = {
-- --             gc_details = false,
-- --             generate = false,           -- Cambiar a false
-- --             regenerate_cgo = false,     -- Cambiar a false
-- --             run_govulncheck = false,    -- Esto es pesado, cambiar a false
-- --             test = false,               -- Cambiar a false
-- --             tidy = false,               -- Cambiar a false
-- --             upgrade_dependency = false, -- Cambiar a false
-- --             vendor = false,             -- Cambiar a false
-- --           },
-- --           hints = {
-- --             rangevariableTypes = true,
-- --             parameterNames = true,
-- --             constantValues = true,
-- --             assingVariableTypes = true,
-- --             compositeLiteralFields = true,
-- --             compositeLiteralTypes = true,
-- --             functionTypeParameters = true,
-- --           },
-- --           usePlaceholders = true,
-- --           completeUnimported = true,
-- --           staticcheck = false,    -- Cambiar a false, es MUY pesado
-- --           directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
-- --           semanticTokens = false, -- Cambiar a false
-- --           -- Añade estas opciones de rendimiento
-- --           ["build.buildFlags"] = { "-tags=integration" },
-- --           env = {
-- --             GOFLAGS = "-tags=integration",
-- --           },
-- --         },
-- --       },
-- --     },
-- --   }
-- -- }
