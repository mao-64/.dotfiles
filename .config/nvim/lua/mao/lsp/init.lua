require'lspconfig'.tsserver.setup{}

require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.jedi_language_server.setup{}
require'lspconfig'.gopls.setup{
	on_attach = function()
		vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer=0})
	end
}
--require'lspconfig'.sumneko_lua.setup{}
require'lspconfig'.lua_ls.setup {}
--require'lspconfig'.lua_ls.setup {
--  settings = {
--    Lua = {
--      runtime = {
--        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--        version = 'LuaJIT',
--        -- Setup your lua path
--        path = "/usr/share/luajit-2.1.0-beta3/jit/",
--      },
--      diagnostics = {
--        -- Get the language server to recognize the `vim` global
--        globals = {'vim'},
--      },
--      workspace = {
--        -- Make the server aware of Neovim runtime files
--        library = vim.api.nvim_get_runtime_file("", true),
--      },
--      -- Do not send telemetry data containing a randomized but unique identifier
--      telemetry = {
--        enable = false,
--      },
--    },
--  },
--}
