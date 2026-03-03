-- Tool Plugins: Claude Code, image viewer, misc utilities

return {
	-- =============================================================================
	-- CLAUDECODE (on keymap/command)
	-- =============================================================================

	{
		"coder/claudecode.nvim",
		cmd = { "ClaudeCode", "ClaudeCodeSend", "ClaudeCodeAdd" },
		keys = {
			{ "<leader>a", "<cmd>ClaudeCode<cr>", mode = { "n", "v", "t" }, desc = "Toggle Claude Code" },
		},
		init = function()
			-- Define highlight groups for Claude Code winbar (orange theme)
			-- NC variants are for unfocused windows (even darker bg, title not bold)
			-- Use autocmd to persist across colorscheme changes
			local function set_claude_hl()
				vim.api.nvim_set_hl(0, "ClaudeCodeTitle", { fg = "#ffffff", bg = "#c15f3c", bold = true })
				vim.api.nvim_set_hl(0, "ClaudeCodeTitleNC", { fg = "#ffffff", bg = "#7b3b25", bold = false })
				vim.api.nvim_set_hl(0, "ClaudeCodeLabel", { fg = "#ffffff", bg = "#c15f3c", bold = false, italic = true })
				vim.api.nvim_set_hl(0, "ClaudeCodeLabelNC", { fg = "#ffffff", bg = "#7b3b25", bold = false, italic = true })
			end
			set_claude_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_claude_hl })

			-- Note: WinEnter/WinLeave redraw is handled by bottom_drawers.lua (consolidated + debounced)

			-- Dynamic winbar function for right-aligned label and width-based hiding
			-- Uses NC variants when window is unfocused for darker background + non-bold title
			function _G._claude_code_winbar()
				local bufnr = vim.api.nvim_get_current_buf()
				local title = vim.b[bufnr].term_title or ""
				if title == "" or title:match("^term://") then
					title = "Claude Code"
				end

				local win = vim.fn.bufwinid(bufnr)
				local width = win > 0 and vim.api.nvim_win_get_width(win) or 80


				if width >= 30 then
					-- Title and label both use winhighlight for consistent background (no inline hl)
					return " " .. title .. " %=,a "
				else
					return " " .. title .. " "
				end
			end

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

			-- Track terminal PIDs for cleanup (snacks deletes buffers before VimLeavePre)
			_G._terminal_pids = _G._terminal_pids or {}

			vim.api.nvim_create_autocmd("TermOpen", {
				callback = function(ev)
					vim.defer_fn(function()
						local buf = ev.buf
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
							local channel = vim.bo[buf].channel
							if channel and channel > 0 then
								local ok, pid = pcall(vim.fn.jobpid, channel)
								if ok and pid and pid > 0 then
									_G._terminal_pids[buf] = pid
								end
							end
						end
					end, 50)
				end,
			})

			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					for _, pid in pairs(_G._terminal_pids or {}) do
						pcall(os.execute, "kill -9 " .. pid .. " 2>/dev/null")
					end
				end,
			})
		end,
		opts = {
			log_level = "warn",
			terminal_cmd = "/opt/homebrew/bin/claude --dangerously-skip-permissions",
			-- Pass full environment so snacks doesn't replace it (jobstart replaces env, doesn't merge)
			env = vim.fn.environ(),
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
						winbar = "%{%v:lua._claude_code_winbar()%}",
						winhighlight = "WinBar:ClaudeCodeTitle,WinBarNC:ClaudeCodeTitleNC",
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
