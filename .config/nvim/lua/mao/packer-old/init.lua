return require('packer').startup({function()
	use "/home/mao/test/notes.nvim/"

	use "wbthomason/packer.nvim"
	use 'neovim/nvim-lspconfig'

	use 'norcalli/nvim-colorizer.lua'

	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/cmp-nvim-lua'

	use "uga-rosa/cmp-dictionary"

	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'
	use "rafamadriz/friendly-snippets"

	use "onsails/lspkind-nvim"

	use 'tpope/vim-surround'

	--use 'liuchengxu/vim-which-key'
	-- Lua
	--use "folke/which-key.nvim"
	use {
  "folke/which-key.nvim",
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}

	--use 'mhinz/vim-startify'

	use "morhetz/gruvbox"
	use 'folke/tokyonight.nvim'
	--use 'ryanoasis/vim-devicons'

	use 'nvim-lua/popup.nvim'
	use 'nvim-lua/plenary.nvim'
	use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	use 'nvim-telescope/telescope.nvim'

	use 'hoob3rt/lualine.nvim'
	use 'kyazdani42/nvim-web-devicons'

	use 'markonm/traces.vim'

	use {
	    'kyazdani42/nvim-tree.lua',
	    requires = 'kyazdani42/nvim-web-devicons',
	    config = function() require'nvim-tree'.setup {} end
	}
	use {
	    'nvim-treesitter/nvim-treesitter',
	    run = ':TSUpdate'
	}

	use { 'nvim-treesitter/playground' }

--	use { "windwp/nvim-autopairs" }

	use { 'tpope/vim-fugitive' }

	use 'Mofiqul/dracula.nvim'
	use { "catppuccin/nvim", as = "catppuccin" }

	use 'glepnir/dashboard-nvim'
--	use {
--  'glepnir/dashboard-nvim',
--  event = 'VimEnter',
--  config = function()
--    require('dashboard').setup {
--	theme = 'doom' --  theme is doom and hyper default is hyper
--      -- config
--    }
--  end,
--  requires = {'nvim-tree/nvim-web-devicons'}
--}

end,
config = {
  display = {
    open_fn = require('packer.util').float,
  }
}})
