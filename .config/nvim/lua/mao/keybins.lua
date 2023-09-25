vim.cmd [[
let mapleader =" "

nnoremap <A-k> :m .-2<CR>==
nnoremap <A-j> :m .+1<CR>==
vnoremap <A-k> :m '<-2<CR>gv=gv
vnoremap <A-j> :m '>+1<CR>gv=gv

"nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
"vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>
]]

vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = false })

vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>zz", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-u>", "<C-u>zz", { noremap = false })

vim.api.nvim_set_keymap("n", "<C-Left>",	":vertical resize +5<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-Right>",	":vertical resize -5<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-UP>",		"resize +5<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-Down>",	"resize -5<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeFocus<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>cn", ":NvimTreeToggle<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>fv", "<cmd>lua require'mao.telescope'.nvim_files()<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fc", "<cmd>lua require'mao.telescope'.conf_files()<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fn", "<cmd>lua require'mao.telescope'.notes()<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fp", "<cmd>lua require'mao.telescope'.project_files()<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope git_files<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope neoclip star<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>tt", ":terminal<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>tn", ":vsplit<CR>:terminal<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>cw", "<cmd>lua require'mao.telescope'.anime_bg()<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>ct", ":w<CR>:!tsc %<CR>", { noremap = false })


--tab
vim.api.nvim_set_keymap("n", "<leader>cc", "<cmd>tabnew<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>tabprevious<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>tabnext<CR>", { noremap = false })

vim.api.nvim_set_keymap("n", "<leader>cs", "<cmd>retab<CR>", { noremap = false })


vim.api.nvim_set_keymap("n", "<leader>wv", "<cmd>vsplit<CR>", { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>wh", "<cmd>split<CR>", { noremap = false })

vim.keymap.set("n", "<leader>-", require("oil").open, { desc = "Open parent directory" })
