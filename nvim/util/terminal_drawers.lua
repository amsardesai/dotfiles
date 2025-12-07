-- Terminal Drawers: Two side-by-side terminal drawers at bottom
-- ,z = primary (left), ,x = secondary (right)

local M = {}

-- Define highlight groups for terminal winbars
vim.api.nvim_set_hl(0, "TerminalZTitle", { fg = "#ffffff", bg = "#2563eb", bold = true }) -- Blue
vim.api.nvim_set_hl(0, "TerminalZHint", { fg = "#93c5fd", bg = "#2563eb", italic = true })
vim.api.nvim_set_hl(0, "TerminalXTitle", { fg = "#ffffff", bg = "#9333ea", bold = true }) -- Purple
vim.api.nvim_set_hl(0, "TerminalXHint", { fg = "#d8b4fe", bg = "#9333ea", italic = true })

M.config = {
	height = 0.3, -- 30% of screen height
}

M.state = {
	primary = { buf = nil, job_id = nil },
	secondary = { buf = nil, job_id = nil },
}

-- Create or get terminal buffer for a slot
local function ensure_terminal(slot)
	local state = M.state[slot]

	-- Check if buffer is still valid
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return state.buf
	end

	-- Create new terminal buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = "terminal"
	state.buf = buf

	-- Start shell in the buffer
	vim.api.nvim_buf_call(buf, function()
		state.job_id = vim.fn.termopen(vim.o.shell, {
			on_exit = function()
				state.buf = nil
				state.job_id = nil
			end,
		})
	end)

	return buf
end

-- Find windows showing our terminal buffers
local function get_terminal_windows()
	local wins = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if buf == M.state.primary.buf then
			wins.primary = win
		elseif buf == M.state.secondary.buf then
			wins.secondary = win
		end
	end
	return wins
end

-- Check if a terminal is visible
local function is_visible(slot)
	local wins = get_terminal_windows()
	return wins[slot] ~= nil
end

-- Calculate terminal height in lines
local function get_height()
	return math.floor(vim.o.lines * M.config.height)
end

-- Set winbar title for a terminal window
local function set_winbar(win, slot)
	local title, key, hl_title, hl_hint
	if slot == "primary" then
		title = "Terminal Z"
		key = ",z"
		hl_title = "TerminalZTitle"
		hl_hint = "TerminalZHint"
	else
		title = "Terminal X"
		key = ",x"
		hl_title = "TerminalXTitle"
		hl_hint = "TerminalXHint"
	end
	-- Full-width colored winbar with title and hint
	vim.wo[win].winbar = "%#" .. hl_title .. "# " .. title .. " %#" .. hl_hint .. "#(type " .. key .. " to toggle) %*"
end

-- Toggle primary terminal (,z)
function M.toggle_primary()
	local wins = get_terminal_windows()

	if wins.primary then
		-- Primary is visible, hide it
		vim.api.nvim_win_close(wins.primary, false)
		-- Secondary will auto-expand to full width
	else
		-- Primary is hidden, show it
		local buf = ensure_terminal("primary")

		local new_win
		if wins.secondary then
			-- Secondary is visible, split it to add primary on left
			vim.api.nvim_set_current_win(wins.secondary)
			vim.cmd("leftabove vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		else
			-- No terminals visible, create bottom split
			vim.cmd("botright split")
			vim.cmd("resize " .. get_height())
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		end

		set_winbar(new_win, "primary")
		vim.cmd("startinsert")
	end
end

-- Toggle secondary terminal (,x)
function M.toggle_secondary()
	local wins = get_terminal_windows()

	if wins.secondary then
		-- Secondary is visible, hide it
		vim.api.nvim_win_close(wins.secondary, false)
		-- Primary will auto-expand to full width
	else
		-- Secondary is hidden, show it
		local buf = ensure_terminal("secondary")

		local new_win
		if wins.primary then
			-- Primary is visible, split it to add secondary on right
			vim.api.nvim_set_current_win(wins.primary)
			vim.cmd("rightbelow vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		else
			-- No terminals visible, create bottom split
			vim.cmd("botright split")
			vim.cmd("resize " .. get_height())
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		end

		set_winbar(new_win, "secondary")
		vim.cmd("startinsert")
	end
end

-- Hide all terminals (close windows but keep buffers)
function M.hide_all()
	local wins = get_terminal_windows()
	if wins.primary then
		vim.api.nvim_win_close(wins.primary, false)
	end
	if wins.secondary then
		vim.api.nvim_win_close(wins.secondary, false)
	end
end

-- Close ALL terminal windows (including Claude, etc.)
function M.close_all_terminal_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

-- Close all terminals (kill processes and buffers)
function M.close_all()
	for _, slot in ipairs({ "primary", "secondary" }) do
		local state = M.state[slot]
		if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
			vim.api.nvim_buf_delete(state.buf, { force = true })
		end
		state.buf = nil
		state.job_id = nil
	end
end

return M
