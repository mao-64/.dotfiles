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
	"ellisonleao/gruvbox.nvim",
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
--	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"onsails/lspkind-nvim",
	"tpope/vim-surround",
	"morhetz/gruvbox",
	"folke/tokyonight.nvim",
	"nvim-lua/popup.nvim",
--	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope.nvim",
	"hoob3rt/lualine.nvim",
	"kyazdani42/nvim-web-devicons",
	"markonm/traces.vim",
	"glepnir/dashboard-nvim",
	"Mofiqul/dracula.nvim",
	"tpope/vim-fugitive",
--	"nvim-treesitter/playground",
	"ThePrimeagen/vim-be-good",
--	"stevearc/oil.nvim",
	"jvgrootveld/telescope-zoxide",
	"AckslD/nvim-neoclip.lua",
	"kkharji/sqlite.lua",
	"xiyaowong/telescope-emoji.nvim",
	--"startup-nvim/startup.nvim",
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
--	{
--		 "folke/which-key.nvim",
--		 config = function()
--			 vim.o.timeout = true
--			 vim.o.timeoutlen = 2000
--			 require("which-key").setup {
--			 }
--		 end
--	},
	-- init.lua:
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },

--	{
--	  'stevearc/oil.nvim',
--	  opts = {},
--	  -- Optional dependencies
--	  dependencies = "nvim-tree/nvim-web-devicons",
--	}
--{
--  "nickjvandyke/opencode.nvim",
--  version = "*", -- Latest stable release
--  dependencies = {
--    {
--      -- `snacks.nvim` integration is recommended, but optional
--      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
--      "folke/snacks.nvim",
--      optional = true,
--      opts = {
--        input = {}, -- Enhances `ask()`
--        picker = { -- Enhances `select()`
--          actions = {
--            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
--          },
--          win = {
--            input = {
--              keys = {
--                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
--              },
--            },
--          },
--        },
--      },
--    },
--  },
--  config = function()
--    ---@type opencode.Opts
--    vim.g.opencode_opts = {
--      -- Your configuration, if any; goto definition on the type or field for details
--    }
--
--    vim.o.autoread = true -- Required for `opts.events.reload`
--
--    -- Recommended/example keymaps
--    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
--    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
--    vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })
--
--    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
--    vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
--
--    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
--    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
--
--    -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
--    vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
--    vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
--  end,
--}
	
  
}

local opts = {}

require("lazy").setup(plugins, opts)
