let g:startify_custom_header = [
	\'     __  ______   ____      _____ __ __',
	\'    /  |/  /   | / __ \    / ___// // /',
	\'   / /|_/ / /| |/ / / /   / __ \/ // /_',
	\'  / /  / / ___ / /_/ /   / /_/ /__  __/',
	\' /_/  /_/_/  |_\____/____\____/  /_/',
	\'                  /_____/',
        \]

let g:startify_lists = [
	\ { 'type': 'files',     'header': ['   Files']            },
	\ { 'type': 'sessions',  'header': ['   Sessions']       },
	\ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
	\ ]
"	\ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },

let g:startify_bookmarks = [
	\ { 'i': '~/.config/nvim/init.lua' },
	\ { 'z': '~/.zshrc' },
	\ { 'a': '~/.config/awesome/rc.lua' },
	\ { 's': '~/.config/sx/sxrc' },
	\ { 'p': '~/.config/polybar/config' },
	\ { 'n': '~/Documents/md/index.md' },
	\ ]
