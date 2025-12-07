-- Keymap helper functions
local M = {}

-- Wrapper for vim.keymap.set with silent default
function M.map(modes, key, action, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(modes, key, action, opts)
end

-- Terminal mode mapping (exits terminal insert mode first)
function M.tmap(key, action, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set("t", key, function()
		vim.cmd("stopinsert")
		if type(action) == "function" then
			action()
		else
			vim.cmd(action:gsub("^:", ""))
		end
	end, opts)
end

-- Terminal mode mapping that passes through if in Claude Code window
function M.tmap_no_claude(key, action, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set("t", key, function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname:match("claude") or bufname:match("ClaudeCode") then
			-- Pass key through to terminal
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
		else
			vim.cmd("stopinsert")
			if type(action) == "function" then
				action()
			else
				vim.cmd(action:gsub("^:", ""))
			end
		end
	end, opts)
end

return M
