vim.wo.number = true
vim.wo.relativenumber = true
vim.o.incsearch = true
vim.wo.list = true
vim.wo.cursorline = true
vim.wo.cursorcolumn = true
vim.o.timeoutlen = 500
vim.o.wrap = false
vim.g.smarttab = true

P = function(v)
	print(vim.inspect(v))
	return v
end

--require "mao.colemak"
require "mao.packer"

require "mao.telescope"

require "mao.cmp-config"

require "mao.luailne"

require "mao.colors"

require "mao.keybins"

require "mao.treesitter"

require "mao.lsp"


require'colorizer'.setup()

require"mao.luasnip"

require("cmp_dictionary").setup({
    dic = {
        --["*"] = { "~/.config/nvim/dictionary" },
        ["*"] = { "~/Documents/md_test/words_test.md" },
    },
})


vim.cmd [[
source ~/.config/nvim/plugconfig/which-key.vim
source ~/.config/nvim/plugconfig/start-screen.vim

set completeopt=menuone,noselect

set shiftwidth=0 noexpandtab

set clipboard+=unnamedplus

set tabstop=3

"set expandtab
set mouse=a

"set dictionary+=~/.config/nvim/dictionary

let g:nvim_tree_respect_buf_cwd = 1
]]
