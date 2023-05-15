local wk = require("which-key")
-- As an example, we will create the following mappings:
--  * <leader>ff find files
--  * <leader>fr show recent files
--  * <leader>fb Foobar
-- we'll document:
--  * <leader>fn new file
--  * <leader>fe edit file
-- and hide <leader>1

wk.register({
  w = {
    name = "windows", -- optional group name
    v = "vertical window", -- same as above
    h = "horizontal window", -- same as above
  },
  f = {
    name = "find", -- optional group name
    f = "find file",
    h = "find hlep",
    g = "find git",
    c = "find config",
  },
}, { prefix = "<leader>" })
