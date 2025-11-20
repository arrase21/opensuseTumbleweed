return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
  settings = {
    Lua = {
      -- hint = {
      --   enable = true,
      -- },
      runtime = { version = "LuaJIT" },
      signatureHelp = { enabled = true },
    },
  },
}
