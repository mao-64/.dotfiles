local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	"wbthomason/packer.nvim",
	"neovim/nvim-lspconfig",
	"norcalli/nvim-colorizer.lua",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-nvim-lua",
	"uga-rosa/cmp-dictionary",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"onsails/lspkind-nvim",
	"tpope/vim-surround",
	"morhetz/gruvbox",
	"folke/tokyonight.nvim",
	"nvim-lua/popup.nvim",
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope.nvim",
	"hoob3rt/lualine.nvim",
	"kyazdani42/nvim-web-devicons",
	"markonm/traces.vim",
	"glepnir/dashboard-nvim",
	"Mofiqul/dracula.nvim",
	"tpope/vim-fugitive",
	"nvim-treesitter/playground",
	{ "catppuccin/nvim", as = "catppuccin" },
	{'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
	{
	    'kyazdani42/nvim-tree.lua',
	    dependencies = 'kyazdani42/nvim-web-devicons',
	    config = function() require'nvim-tree'.setup {} end
	},
	{
	    'nvim-treesitter/nvim-treesitter',
	    run = ':TSUpdate'
	},
	{
		 "folke/which-key.nvim",
		 config = function()
			 vim.o.timeout = true
			 vim.o.timeoutlen = 300
			 require("which-key").setup {
			 }
		 end
	}
}

local opts = {}

require("lazy").setup(plugins, opts)
