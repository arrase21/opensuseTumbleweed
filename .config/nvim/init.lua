local configs = vim.tbl_map(function(path)
  return vim.fn.fnamemodify(path, ':t:r')
end, vim.api.nvim_get_runtime_file('lsp/*.lua', true))

vim.lsp.enable(configs)

-- Plugins =====================================================================================================
vim.pack.add({
  --Themes =====================================================================================================
  { src = "https://github.com/craftzdog/solarized-osaka.nvim" },
  { src = "https://github.com/rebelot/kanagawa.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://gitlab.com/motaz-shokry/gruvbox.nvim" },
  -- ===========================================================================================================
  { src = "https://github.com/mistweaverco/kulala.nvim" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- dap  ======================================================================================================
  { src = "https://github.com/mfussenegger/nvim-dap"},
  { src = "https://github.com/mfussenegger/nvim-dap-python"},
  { src = "https://github.com/rcarriga/nvim-dap-ui"},
  { src = "https://github.com/leoluz/nvim-dap-go"},
  { src = "https://github.com/nvim-neotest/nvim-nio"}
})

--AutoCmd or configs ===========================================================================================
_G.Config = _G.Config or {}
local gr = vim.api.nvim_create_augroup('custom-config', {})
_G.Config.new_autocmd = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, {
    group = gr,
    pattern = pattern,
    callback = callback,
    desc = desc,
  })
end

-- Themes ==================================================================
require('plugins.themes')
-- vim.cmd('colorscheme tokyonight')
-- vim.cmd('colorscheme solarized-osaka')
-- vim.cmd("colorscheme kanagawa-wave")
vim.cmd("colorscheme gruvbox-soft")
