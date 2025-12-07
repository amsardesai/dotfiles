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
			{ "<leader>sa", "<cmd>ClaudeCodeAdd<cr>", desc = "Add file to Claude" },
		},
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
				},
			},
			diff_opts = { vertical_split = false },
		},
	},

	-- =============================================================================
	-- IMAGE.NVIM (BufRead for image files)
	-- =============================================================================

	{
		"3rd/image.nvim",
		event = "BufReadPre *.png,*.jpg,*.jpeg,*.gif,*.webp,*.bmp,*.ico,*.svg",
		build = false,
		config = function()
			local ok, image = pcall(require, "image")
			if ok then
				image.setup({
					backend = "kitty",
					processor = "magick_cli",
					integrations = {
						markdown = { enabled = false },
						neorg = { enabled = false },
						typst = { enabled = false },
						html = { enabled = false },
						css = { enabled = false },
					},
					max_height_window_percentage = 80,
					max_width_window_percentage = 80,
					hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.ico", "*.svg" },
				})
			end
		end,
	},
}
