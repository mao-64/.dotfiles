--local z_utils = require("telescope._extensions.zoxide.utils")
require("os")
require('telescope').setup {
	defaults = {
		preview = {
      mime_hook = function(filepath, bufnr, opts)
        local is_image = function(filepath)
          local image_extensions = {'png','jpg'}   -- Supported image formats
          local split_path = vim.split(filepath:lower(), '.', {plain=true})
          local extension = split_path[#split_path]
          return vim.tbl_contains(image_extensions, extension)
        end
        if is_image(filepath) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local function send_output(_, data, _ )
            for _, d in ipairs(data) do
              vim.api.nvim_chan_send(term, d..'\r\n')
            end
          end
          vim.fn.jobstart(
            {
              'catimg', filepath  -- Terminal image viewer command
            }, 
            {on_stdout=send_output, stdout_buffered=true, pty=true})
        else
          require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
        end
      end
    },
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
      --theme = "ivy"
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
    },
	 zoxide = {
      prompt_title = "[ Walking on the shoulders of TJ ]",
      mappings = {
        default = {
          after_action = function(selection)
            print("Update to (" .. selection.z_score .. ") " .. selection.path)
          end
        }
	   }
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

M.notes = function()
	require("telescope.builtin").find_files({
		prompt_title = "< notes >",
		cwd = "~/Documents/md//",
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

M.project_files = function()
  local opts = {
	  file_ignore_patterns = {'node_modules/.*'}
  } -- define here if you want to define something
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require"telescope.builtin".git_files(opts)
  else
    require"telescope.builtin".find_files(opts)
  end
end

return M
