require('base16-colorscheme').setup({
  base00 = "#191113",
  base01 = "#140c0e",
  base02 = "#22191b",
  base03 = "#524345",
  base04 = "#d6c2c4",
  base05 = "#efdee0",
  base06 = "#382e2f",
  base07 = "#413738",

  base08 = "#e8b17b",
  base09 = "#ecbe91",
  base0A = "#e4bdc3",
  base0B = "#ffb1c1",
  base0C = "#60401d",
  base0D = "#713343",
  base0E = "#5b3f45",
  base0F = "#d599a2",
})

-- Helper function to set multiple highlight groups at once
local function set_hl_mutliple(groups, value)
  for _, v in pairs(groups) do
    vim.api.nvim_set_hl(0, v, value)
  end
end

-- Make selected text stand out more
vim.api.nvim_set_hl(0, 'Visual', {
  bg = '#713343',
  fg = '#ffd9df', -- normal text contrast
})

-- Make "string" text contrast better
set_hl_mutliple({ 'String', 'TSString' }, {
  fg = '#e19750',
})

-- Grey out comments
set_hl_mutliple({ 'TSComment', 'Comment' }, {
  fg = '#9e8c8f',
  italic = true,
})

-- Color in other highlight groups as you see fit!

set_hl_mutliple({ 'TSMethod', 'Method' }, {
  fg = '#ecbe91',
})


set_hl_mutliple({ 'TSFunction', 'Function' }, {
  fg = '#e4bdc3',
})

set_hl_mutliple({ 'Keyword', 'TSKeyword', 'TSKeywordFunction', 'TSRepeat' }, {
  fg = '#8d4a5a',
})

require("lualine").setup({
  options = { theme = "base16" }
})
