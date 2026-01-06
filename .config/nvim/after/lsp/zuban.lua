---@type vim.lsp.Config
return {
  cmd = { 'zuban', 'server' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  on_exit = function(code, _, _)
    vim.notify('Closing Pyrefly LSP exited with code: ' .. code, vim.log.levels.INFO)
  end,
}
