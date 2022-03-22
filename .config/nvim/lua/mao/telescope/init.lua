require("os")
require('telescope').setup {
	defaults = {
		sorting_strategy = "ascending",
		layout_config = {
--			prompt_position = "top",
--			prompt_position = "bottom",
--			themes.get_ivy,
		}
	},
	pickers = {
	    -- Your special builtin config goes in here
	    buffers = {
	      sort_lastused = true,
	      theme = "ivy",
	      previewer = false,
	    },
    find_files = {
      theme = "ivy"
    },
    help_tags = {
      theme = "ivy"
    }
  },
	extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  },
  color_devicons = true,
}
require('telescope').load_extension('fzf')


local M = {}
M.nvim_files = function()
	require("telescope.builtin").find_files({
		prompt_title = "< NeoVimRC >",
		cwd = "~/.config/nvim/",
	})
end

M.conf_files = function()
	require("telescope.builtin").find_files({
		prompt_title = "< .config >",
		cwd = "~/.config/",
	})
end

M.anime_bg = function()
	require("telescope.builtin").find_files({
		prompt_title = "< BG >",
		cwd = "~/Pictures/wallpaper",
		attach_mappings = function(prompt_bufnr, map)
			function set_the_background(close)
				local content = require("telescope.actions.state").get_selected_entry(bufnr)
			os.execute("feh --bg-scale ".. content.cwd .. "/" .. content.value)
			if close then
				require("telescope.actions").close(prompt_bufnr)
			end
		end

		map("i", "<C-p>", function(bufnr)
			set_the_background()
		end)

		map("i", "<CR>", function(bufnr)
			set_the_background(true)
		end)

		map("n", "<CR>", function(bufnr)
			set_the_background(true)
		end)
		return true
	end	
	})
end

return M
