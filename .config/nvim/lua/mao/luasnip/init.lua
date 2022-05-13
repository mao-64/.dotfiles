local ls = require "luasnip"
local types = require "luasnip.util.types"
require "os"

ls.config.set_config {
	history = true,

	upfateevents = "TextChanged,TextChangedI",

	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "<-", "Error" } },
			},
		}, }, }

vim.keymap.set("i", "<c-x>", function()
	if ls and ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = false})

require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/snippets"})

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/mao/luasnip/init.lua<CR>")



