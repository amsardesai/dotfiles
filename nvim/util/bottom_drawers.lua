-- Bottom Drawers: Side-by-side drawers at bottom of screen
-- ,z = Terminal Z (left), ,x = Terminal X (middle), ,t = Trouble (right)

local M = {}

-- Define highlight groups for drawer winbars
vim.api.nvim_set_hl(0, "TerminalZTitle", { fg = "#ffffff", bg = "#2563eb", bold = true }) -- Blue
vim.api.nvim_set_hl(0, "TerminalZHint", { fg = "#93c5fd", bg = "#2563eb", italic = true })
vim.api.nvim_set_hl(0, "TerminalXTitle", { fg = "#ffffff", bg = "#9333ea", bold = true }) -- Purple
vim.api.nvim_set_hl(0, "TerminalXHint", { fg = "#d8b4fe", bg = "#9333ea", italic = true })
vim.api.nvim_set_hl(0, "TroubleTitle", { fg = "#ffffff", bg = "#dc2626", bold = true }) -- Red
vim.api.nvim_set_hl(0, "TroubleHint", { fg = "#fca5a5", bg = "#dc2626", italic = true })

M.config = {
	height = 0.3, -- 30% of screen height
}

M.state = {
	primary = { buf = nil, job_id = nil }, -- Terminal Z
	secondary = { buf = nil, job_id = nil }, -- Terminal X
	trouble = { win = nil }, -- Trouble (no buf tracking, managed by trouble.nvim)
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

-- Find windows showing our drawer buffers
local function get_drawer_windows()
	local wins = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if buf == M.state.primary.buf then
			wins.primary = win
		elseif buf == M.state.secondary.buf then
			wins.secondary = win
		elseif vim.bo[buf].filetype == "trouble" then
			wins.trouble = win
			M.state.trouble.win = win
		end
	end
	return wins
end

-- Get the rightmost open drawer window (for positioning new drawers)
local function get_rightmost_drawer(wins)
	-- Order: primary (left) -> secondary (middle) -> trouble (right)
	if wins.trouble then
		return wins.trouble
	elseif wins.secondary then
		return wins.secondary
	elseif wins.primary then
		return wins.primary
	end
	return nil
end

-- Calculate drawer height in lines
local function get_height()
	return math.floor(vim.o.lines * M.config.height)
end

-- Set winbar title for a drawer window
local function set_winbar(win, slot)
	local title, key, hl_title, hl_hint
	if slot == "primary" then
		title = "Terminal Z"
		key = ",z"
		hl_title = "TerminalZTitle"
		hl_hint = "TerminalZHint"
	elseif slot == "secondary" then
		title = "Terminal X"
		key = ",x"
		hl_title = "TerminalXTitle"
		hl_hint = "TerminalXHint"
	elseif slot == "trouble" then
		title = "Trouble.nvim Diagnostics"
		key = ",t"
		hl_title = "TroubleTitle"
		hl_hint = "TroubleHint"
	end
	-- Full-width colored winbar with title and hint
	vim.wo[win].winbar = "%#" .. hl_title .. "# " .. title .. " %#" .. hl_hint .. "#(type " .. key .. " to toggle) %*"
end

-- Toggle primary terminal (,z)
function M.toggle_primary()
	local wins = get_drawer_windows()

	if wins.primary then
		-- Primary is visible, hide it
		vim.api.nvim_win_close(wins.primary, false)
	else
		-- Primary is hidden, show it
		local buf = ensure_terminal("primary")

		local new_win
		-- Check what's already open to position correctly (primary goes leftmost)
		local any_open = wins.secondary or wins.trouble
		if any_open then
			-- Split to the left of the leftmost existing drawer
			local leftmost = wins.secondary or wins.trouble
			vim.api.nvim_set_current_win(leftmost)
			vim.cmd("leftabove vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		else
			-- No drawers visible, create bottom split
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
	local wins = get_drawer_windows()

	if wins.secondary then
		-- Secondary is visible, hide it
		vim.api.nvim_win_close(wins.secondary, false)
	else
		-- Secondary is hidden, show it
		local buf = ensure_terminal("secondary")

		local new_win
		if wins.primary and wins.trouble then
			-- Both primary and trouble open: insert secondary between them
			vim.api.nvim_set_current_win(wins.primary)
			vim.cmd("rightbelow vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		elseif wins.primary then
			-- Only primary open: secondary goes to the right
			vim.api.nvim_set_current_win(wins.primary)
			vim.cmd("rightbelow vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		elseif wins.trouble then
			-- Only trouble open: secondary goes to the left of trouble
			vim.api.nvim_set_current_win(wins.trouble)
			vim.cmd("leftabove vsplit")
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		else
			-- No drawers visible, create bottom split
			vim.cmd("botright split")
			vim.cmd("resize " .. get_height())
			new_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(new_win, buf)
		end

		set_winbar(new_win, "secondary")
		vim.cmd("startinsert")
	end
end

-- Toggle trouble drawer (,t)
function M.toggle_trouble()
	-- First, ensure trouble.nvim is loaded
	local ok, trouble = pcall(require, "trouble")
	if not ok then
		vim.notify("trouble.nvim not installed", vim.log.levels.ERROR)
		return
	end

	-- Check if trouble is currently open
	if trouble.is_open() then
		trouble.close()
		M.state.trouble.win = nil
	else
		local wins = get_drawer_windows()
		local rightmost = wins.secondary or wins.primary

		if rightmost then
			-- Focus on rightmost drawer, then open trouble relative to it
			vim.api.nvim_set_current_win(rightmost)
			trouble.open({
				mode = "diagnostics",
				focus = true,
				win = {
					type = "split",
					relative = "win",
					position = "right",
					size = 0.5,
				},
			})
		else
			-- No drawers visible, open trouble at bottom
			trouble.open({
				mode = "diagnostics",
				focus = true,
				win = {
					type = "split",
					relative = "editor",
					position = "bottom",
					size = get_height(),
				},
			})
		end

		-- Find trouble window by searching for trouble filetype (with retry)
		local function apply_trouble_winbar(attempts)
			attempts = attempts or 0
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_is_valid(w) then
					local buf = vim.api.nvim_win_get_buf(w)
					local ft = vim.bo[buf].filetype
					if ft == "trouble" then
						set_winbar(w, "trouble")
						M.state.trouble.win = w
						return
					end
				end
			end
			-- Retry up to 10 times (100ms total) if not found yet
			if attempts < 10 then
				vim.defer_fn(function()
					apply_trouble_winbar(attempts + 1)
				end, 10)
			end
		end

		vim.defer_fn(function()
			apply_trouble_winbar(0)
		end, 10)
	end
end

-- Hide all drawers (close windows but keep terminal buffers)
function M.hide_all()
	local wins = get_drawer_windows()
	if wins.primary then
		vim.api.nvim_win_close(wins.primary, false)
	end
	if wins.secondary then
		vim.api.nvim_win_close(wins.secondary, false)
	end
	if wins.trouble then
		vim.api.nvim_win_close(wins.trouble, false)
		M.state.trouble.win = nil
	end
end

-- Close ALL drawer windows (terminals + trouble + Claude, etc.)
function M.close_all_drawer_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if vim.bo[buf].buftype == "terminal" or ft == "trouble" then
			vim.api.nvim_win_close(win, false)
		end
	end
	M.state.trouble.win = nil
end

-- Kill all terminal processes and buffers (doesn't affect trouble)
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
