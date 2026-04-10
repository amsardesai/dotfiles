-- Bottom Drawers: Dynamic side-by-side drawers at bottom of screen
-- Order is based on when drawers are opened (left-to-right = first-to-last opened)
-- ,z = Terminal Z, ,x = Terminal X

-- Cache module to preserve state across dofile() calls
if _G._bottom_drawers then
	return _G._bottom_drawers
end

local M = {}

-- Define highlight groups for drawer winbars (persist across colorscheme changes)
-- Each drawer has Title (bold) and Label (italic) variants with same background
-- NC variants are for unfocused windows (even darker bg, title not bold)
local function set_drawer_highlights()
	-- Terminal Z (blue) - focused=600, unfocused=800 (darker)
	vim.api.nvim_set_hl(0, "TerminalZTitle", { fg = "#ffffff", bg = "#2563eb", bold = true })
	vim.api.nvim_set_hl(0, "TerminalZTitleNC", { fg = "#ffffff", bg = "#1e40af", bold = false })
	vim.api.nvim_set_hl(0, "TerminalZLabel", { fg = "#ffffff", bg = "#2563eb", bold = false, italic = true })
	vim.api.nvim_set_hl(0, "TerminalZLabelNC", { fg = "#ffffff", bg = "#1e40af", bold = false, italic = true })

	-- Terminal X (purple) - focused=600, unfocused=800 (darker)
	vim.api.nvim_set_hl(0, "TerminalXTitle", { fg = "#ffffff", bg = "#9333ea", bold = true })
	vim.api.nvim_set_hl(0, "TerminalXTitleNC", { fg = "#ffffff", bg = "#6b21a8", bold = false })
	vim.api.nvim_set_hl(0, "TerminalXLabel", { fg = "#ffffff", bg = "#9333ea", bold = false, italic = true })
	vim.api.nvim_set_hl(0, "TerminalXLabelNC", { fg = "#ffffff", bg = "#6b21a8", bold = false, italic = true })
end
set_drawer_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_drawer_highlights })

-- Debounced redraw on window focus changes to update dynamic winbar expressions
-- Uses vim.schedule() to coalesce rapid WinEnter/WinLeave events into single redraw
-- This also handles agent terminal winbar updates (removed duplicate autocmd)
local redraw_pending = false
vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
	callback = function()
		if not redraw_pending then
			redraw_pending = true
			vim.schedule(function()
				vim.cmd("redraw")
				redraw_pending = false
			end)
		end
	end,
	desc = "Debounced redraw to update drawer and agent winbars on focus change",
})

M.config = {
	height = 0.3, -- 30% of screen height
}

-- State tracks open order and drawer-specific data
M.state = {
	-- Ordered list of open drawer IDs (in open order, left-to-right)
	open_order = {}, -- e.g., {"primary", "secondary"}

	-- Drawer-specific data
	drawers = {
		primary = { buf = nil, job_id = nil },
		secondary = { buf = nil, job_id = nil },
	},
}

-- Drawer metadata for winbars
-- bold_title: static bold text (nil = use term_title dynamically)
-- label: suffix text, hl_title: bold highlight, hl_label: italic highlight
local drawer_meta = {
	primary = { bold_title = nil, label = ",z", hl_title = "TerminalZTitle", hl_label = "TerminalZLabel" },
	secondary = { bold_title = nil, label = ",x", hl_title = "TerminalXTitle", hl_label = "TerminalXLabel" },
}

-- =============================================================================
-- Helper Functions
-- =============================================================================

-- Check if a slot is in the open_order
local function is_drawer_open(slot)
	for _, s in ipairs(M.state.open_order) do
		if s == slot then
			return true
		end
	end
	return false
end

-- Add slot to end of open_order (rightmost position)
local function add_to_open_order(slot)
	if not is_drawer_open(slot) then
		table.insert(M.state.open_order, slot)
	end
end

-- Remove slot from open_order
local function remove_from_open_order(slot)
	for i, s in ipairs(M.state.open_order) do
		if s == slot then
			table.remove(M.state.open_order, i)
			return
		end
	end
end

-- Calculate drawer height in lines
local function get_height()
	return math.floor(vim.o.lines * M.config.height)
end

-- Global function for dynamic winbar content (called by winbar %{} expression)
-- Returns formatted text with inline highlights (bold title + right-aligned italic label)
-- Uses NC variants when window is unfocused for darker background + non-bold title
function _G._bottom_drawer_winbar(bufnr, slot)
	local meta = drawer_meta[slot]
	if not meta then
		return ""
	end
	local title = meta.bold_title or vim.b[bufnr].term_title or "zsh"

	-- Get window width to conditionally show label
	local win = vim.fn.bufwinid(bufnr)
	local width = win > 0 and vim.api.nvim_win_get_width(win) or 80

	if width >= 30 then
		-- Title and label both use winhighlight for consistent background (no inline hl)
		return " " .. title .. " %=" .. meta.label .. " "
	else
		-- Narrow: hide label
		return " " .. title .. " "
	end
end

-- Set winbar title for a drawer window
local function set_winbar(win, slot)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	local meta = drawer_meta[slot]
	if not meta then
		return
	end
	local buf = vim.api.nvim_win_get_buf(win)

	-- Use dynamic winbar that re-evaluates on each redraw
	vim.wo[win].winbar = "%{%v:lua._bottom_drawer_winbar(" .. buf .. ", '" .. slot .. "')%}"
	-- Apply full-width background via winhighlight (uses NC variant when unfocused)
	vim.wo[win].winhighlight = "WinBar:" .. meta.hl_title .. ",WinBarNC:" .. meta.hl_title .. "NC"

	-- Disable line numbers for terminal drawers
	if slot == "primary" or slot == "secondary" then
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
	end
end

-- Find window for a specific drawer slot
local function find_drawer_window(slot)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if not vim.api.nvim_win_is_valid(win) then
			goto continue
		end
		local buf = vim.api.nvim_win_get_buf(win)

		-- Terminal drawers
		if slot == "primary" and buf == M.state.drawers.primary.buf then
			return win
		elseif slot == "secondary" and buf == M.state.drawers.secondary.buf then
			return win
		end

		::continue::
	end
	return nil
end

-- Get all open drawer windows in order
local function get_open_drawer_windows()
	local result = {}
	for _, slot in ipairs(M.state.open_order) do
		local win = find_drawer_window(slot)
		if win then
			table.insert(result, { slot = slot, win = win })
		end
	end
	return result
end

-- Create or get terminal buffer for a slot
local function ensure_terminal(slot)
	local state = M.state.drawers[slot]

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

-- =============================================================================
-- Rebalance: Resize all open drawers to equal width
-- =============================================================================

local function rebalance_drawers()
	local open_wins = get_open_drawer_windows()
	local count = #open_wins

	if count == 0 then
		return
	end

	-- Calculate equal width for each drawer
	local total_width = vim.o.columns
	local each_width = math.floor(total_width / count)

	-- Resize each window and apply winbar
	for _, drawer in ipairs(open_wins) do
		if vim.api.nvim_win_is_valid(drawer.win) then
			vim.api.nvim_win_set_width(drawer.win, each_width)
			set_winbar(drawer.win, drawer.slot)
		end
	end
end

-- =============================================================================
-- Open/Close Drawer Functions
-- =============================================================================

-- Open a drawer (creates window, adds to open_order, rebalances)
local function open_drawer(slot, buf_or_cmd)
	local open_wins = get_open_drawer_windows()
	local new_win

	if #open_wins == 0 then
		-- No drawers visible, create bottom split
		vim.cmd("botright split")
		vim.cmd("resize " .. get_height())
		new_win = vim.api.nvim_get_current_win()
	else
		-- Drawers exist, vsplit to the right of rightmost
		local rightmost = open_wins[#open_wins]
		vim.api.nvim_set_current_win(rightmost.win)
		vim.cmd("rightbelow vsplit")
		new_win = vim.api.nvim_get_current_win()
	end

	-- Set buffer if provided (for terminals)
	if type(buf_or_cmd) == "number" then
		vim.api.nvim_win_set_buf(new_win, buf_or_cmd)
	end

	add_to_open_order(slot)
	rebalance_drawers()

	return new_win
end

-- Close a drawer (closes window, removes from open_order, rebalances)
local function close_drawer(slot)
	local win = find_drawer_window(slot)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, false)
	end
	remove_from_open_order(slot)
	rebalance_drawers()
end

-- =============================================================================
-- Toggle Functions
-- =============================================================================

-- Toggle primary terminal (,z)
function M.toggle_primary()
	if is_drawer_open("primary") then
		close_drawer("primary")
	else
		local buf = ensure_terminal("primary")
		local win = open_drawer("primary", buf)
		set_winbar(win, "primary")
		vim.cmd("startinsert")
	end
end

-- Toggle secondary terminal (,x)
function M.toggle_secondary()
	if is_drawer_open("secondary") then
		close_drawer("secondary")
	else
		local buf = ensure_terminal("secondary")
		local win = open_drawer("secondary", buf)
		set_winbar(win, "secondary")
		vim.cmd("startinsert")
	end
end

-- =============================================================================
-- Cleanup Functions
-- =============================================================================

-- Hide all drawers (close windows but keep terminal buffers)
function M.hide_all()
	-- Close in reverse order to avoid layout issues
	local slots_to_close = {}
	for _, slot in ipairs(M.state.open_order) do
		table.insert(slots_to_close, slot)
	end

	for i = #slots_to_close, 1, -1 do
		local slot = slots_to_close[i]
		local win = find_drawer_window(slot)
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, false)
		end
	end

	M.state.open_order = {}
end

-- Close ALL drawer windows (including killing terminal processes)
function M.close_all_drawer_windows()
	M.hide_all()

	-- Also kill terminal processes
	for _, slot in ipairs({ "primary", "secondary" }) do
		local state = M.state.drawers[slot]
		if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
			vim.api.nvim_buf_delete(state.buf, { force = true })
		end
		state.buf = nil
		state.job_id = nil
	end
end

-- Kill all terminal processes (doesn't affect other drawers)
function M.close_all()
	for _, slot in ipairs({ "primary", "secondary" }) do
		local state = M.state.drawers[slot]
		if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
			vim.api.nvim_buf_delete(state.buf, { force = true })
		end
		state.buf = nil
		state.job_id = nil
		remove_from_open_order(slot)
	end
	rebalance_drawers()
end

-- Store in global for caching
_G._bottom_drawers = M

return M
