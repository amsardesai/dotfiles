-- Tool Plugins: Claude Code, image viewer, misc utilities

return {
	-- =============================================================================
	-- CLAUDECODE (on keymap/command)
	-- =============================================================================

	{
		"coder/claudecode.nvim",
		cmd = { "ClaudeCode", "ClaudeCodeSend", "ClaudeCodeAdd" },
		keys = {
			{ "<leader>a", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude Code" },
			{ "<leader>a", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		},
		init = function()
			-- Define highlight groups for Claude Code winbar (orange theme)
			vim.api.nvim_set_hl(0, "ClaudeCodeTitle", { fg = "#ffffff", bg = "#ea580c", bold = true })
			vim.api.nvim_set_hl(0, "ClaudeCodeHint", { fg = "#fed7aa", bg = "#ea580c", italic = true })

			-- Apply orange winbar to Claude Code terminal via filetype detection
			-- snacks terminal sets filetype to "snacks_terminal"
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "snacks_terminal",
				callback = function(args)
					-- Defer to ensure window is ready
					vim.defer_fn(function()
						local buf = args.buf
						if not vim.api.nvim_buf_is_valid(buf) then
							return
						end
						-- Find window showing this buffer
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
								-- Check if this is a right-side split (Claude Code)
								local pos = vim.api.nvim_win_get_position(win)
								if pos[2] > vim.o.columns * 0.3 then
									vim.wo[win].winbar =
										"%#ClaudeCodeTitle# %{b:term_title} %#ClaudeCodeHint#(type ,a to toggle) %*"
								end
							end
						end
					end, 150)
				end,
			})

			-- Auto-open Claude Code when launching with a directory
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- Same condition as neo-tree: only when opening directory
					local argc = vim.fn.argc()
					local is_directory = argc == 1 and vim.fn.isdirectory(data.file) == 1
					local should_auto_open = argc == 0 or is_directory

					if not should_auto_open then
						return
					end

					-- Defer to ensure neo-tree is ready first, then open Claude Code
					vim.defer_fn(function()
						require("lazy").load({ plugins = { "claudecode.nvim" } })
						vim.cmd("ClaudeCode")

						-- Focus the Claude Code terminal (rightmost window)
						vim.defer_fn(function()
							local max_col = -1
							local target_win = nil
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								if vim.api.nvim_win_is_valid(win) then
									local pos = vim.api.nvim_win_get_position(win)
									if pos[2] > max_col then
										max_col = pos[2]
										target_win = win
									end
								end
							end
							if target_win then
								vim.api.nvim_set_current_win(target_win)
								vim.cmd("startinsert")
							end
						end, 100)
					end, 100)
				end,
			})
		end,
		opts = {
			log_level = "warn",
			terminal = {
				split_side = "right",
				split_width_percentage = 0.40,
				provider = "snacks",
				snacks_win_opts = {
					width = function()
						local editor_width = vim.o.columns
						local percentage_width = math.floor(editor_width * 0.40)
						return math.min(percentage_width, 75)
					end,
					wo = {
						winbar = "%#ClaudeCodeTitle# %{b:term_title} %#ClaudeCodeHint#(type ,a to toggle) %*",
					},
				},
			},
			diff_opts = {
				layout = "vertical",
				auto_close_on_accept = true,
				keep_terminal_focus = true,
			},
		},
	},

}
