require("os")

function Maotest()
	os.execute("st & disown")
end


function BGtest()
		require("telescope.builtin").find_files({
			prompt_title = "< BG >",
			cwd = "~/Pictures/wallpaper",
			attach_mappings = function(prompt_bufnr, map)
				function set_the_background(close)
					local content = require("telescope.actions.stats").get_selected_entry(bufnr)
				os.execute("feh --bg-scale ~/Pictures/wallpaper".. content.value)
				if close then
					require("telescope,actions").close(prompt_bufnr)
				end
			end

			map("i", "<C-p>", function(bufnr)
				set_the_background()
			end)

			map("i", "<CR>", function(bufnr)
				set_the_background(true)
			end)
			return true
		end	
		})

		--os.execute("feh --bg-scale ~/Pictures/wallpaper".. x)
end

--function ColemakIN()
--	local mode_code = vim.api.nvim_get_mode().mode
--	os.execute("xmodmap ~/.config/colemakdhtest")
--	--os.execute("notify-send ".. mode_code)
--end
--
--function ColemakOUT()
--	os.execute("setxkbmap")
--end

--vim.cmd [[
--autocmd VimEnter * lua ColemakOUT()
--autocmd InsertEnter * lua ColemakIN()
--autocmd InsertLeave * lua ColemakOUT()
--autocmd VimLeave * lua ColemakIN()
--]]
