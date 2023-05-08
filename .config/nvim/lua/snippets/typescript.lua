local ls = require "luasnip"

return {
	ls.parser.parse_snippet("cin", "const $1 = require(\"$2\");")
}

