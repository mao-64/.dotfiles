vim.wo.number = true
vim.wo.relativenumber = true
vim.o.incsearch = true
vim.wo.list = true
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
vim.o.timeoutlen = 500
vim.o.wrap = false
vim.g.smarttab = true

--require "mao.colemak"

require "mao.packer"

require "mao.telescope"

require "mao.cmp-config"

require "mao.luailne"

require "mao.colors"

require "mao.keybins"

require "mao.treesitter"

require "mao.testing"

require'lspconfig'.tsserver.setup{}
--require'lspconfig'.pyright.setup{}

require'nvim-tree'.setup {}

require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.jedi_language_server.setup{}

require'colorizer'.setup()

vim.cmd [[
source ~/.config/nvim/plugconfig/which-key.vim
source ~/.config/nvim/plugconfig/start-screen.vim
"source ~/.config/nvim/lua/mao/lsp/lsp.vim

set completeopt=menuone,noselect

set shiftwidth=0 noexpandtab

set clipboard+=unnamedplus

set tabstop=5

set dictionary+=~/.config/nvim/dictionary

let g:nvim_tree_respect_buf_cwd = 1
]]
