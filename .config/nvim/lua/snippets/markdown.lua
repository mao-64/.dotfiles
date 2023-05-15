local ls = require "luasnip"
local types = require "luasnip.util.types"
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node

return {
		s("ml", fmt("[[{}.md]]{}", { i(1), i(0) })),

		s("date", {
		f(function() return os.date("%Y-%m-%d") end),
		t(": "),
		i(1, "pp poo poo"),
		t("-lb"),
		i(0)}),
}
