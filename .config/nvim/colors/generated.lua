require('base16-colorscheme').setup({
	base00 = "#131318",
	base01 = "#0e0e13",
	base02 = "#1b1b21",
	base03 = "#46464f",
	base04 = "#c7c5d0",
	base05 = "#e4e1e9",
	base06 = "#303036",
	base07 = "#39383f",

	base08 = "#e2a6c8",
	base09 = "#e8b9d4",
	base0A = "#c5c4dd",
	base0B = "#bfc1ff",
	base0C = "#5f3c52",
	base0D = "#3e4178",
	base0E = "#454559",
	base0F = "#a5a4ca",
})

-- Helper function to set multiple highlight groups at once
local function set_hl_mutliple(groups, value)
	for _, v in pairs(groups) do
		vim.api.nvim_set_hl(0, v, value)
	end
end

-- Make selected text stand out more
vim.api.nvim_set_hl(0, 'Visual', {
	bg = '#3e4178',
	fg = '#e1e0ff', -- normal text contrast
})

-- Make "string" text contrast better
set_hl_mutliple({ 'String', 'TSString' }, {
	fg = '#d57fb1',
})

-- Grey out comments
set_hl_mutliple({ 'TSComment', 'Comment' }, {
	fg = '#918f9a',
	italic = true,
})

-- Color in other highlight groups as you see fit!

set_hl_mutliple({ 'TSMethod', 'Method' }, {
	fg = '#e8b9d4',
})


set_hl_mutliple({ 'TSFunction', 'Function' }, {
	fg = '#c5c4dd',
})

set_hl_mutliple({ 'Keyword', 'TSKeyword', 'TSKeywordFunction', 'TSRepeat' }, {
	fg = '#565992',
})

-- require("lualine").setup({
--   options = { theme = "base16" }
-- })
