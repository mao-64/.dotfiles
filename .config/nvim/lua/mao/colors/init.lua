vim.wo.colorcolumn = "80,100"
vim.g.tokyonight_style = "night"
--vim.g.tokyonight_style = "storm"
--vim.g.tokyonight_style = "moon"

vim.cmd [[
let g:solarized_termcolors=256
"colorscheme tokyonight
colorscheme tokyonight-storm
set termguicolors

"highlight link CompeDocumentation NormalFloat
"au ColorScheme * hi Normal ctermbg=none guibg=none
"au ColorScheme * hi NormalNC ctermbg=none guibg=none
"au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none

hi NvimTreeNormal ctermbg=none guibg=none
hi NormalNC ctermbg=none guibg=none
hi normal ctermbg=none guibg=none
]]
