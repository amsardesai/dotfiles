-- Bottom Drawers: Dynamic side-by-side drawers at bottom of screen
-- Order is based on when drawers are opened (left-to-right = first-to-last opened)
-- ,z = Terminal Z, ,x = Terminal X, ,b = Buffers, ,s = Git Status, ,d = Symbols, ,t = Trouble

-- Cache module to preserve state across dofile() calls
if _G._bottom_drawers then
	return _G._bottom_drawers
end

local M = {}

-- Define highlight groups for drawer winbars
vim.api.nvim_set_hl(0, "TerminalZTitle", { fg = "#ffffff", bg = "#2563eb", bold = true }) -- Blue
vim.api.nvim_set_hl(0, "TerminalZHint", { fg = "#93c5fd", bg = "#2563eb", italic = true })
vim.api.nvim_set_hl(0, "TerminalXTitle", { fg = "#ffffff", bg = "#9333ea", bold = true }) -- Purple
vim.api.nvim_set_hl(0, "TerminalXHint", { fg = "#d8b4fe", bg = "#9333ea", italic = true })
vim.api.nvim_set_hl(0, "TroubleTitle", { fg = "#ffffff", bg = "#dc2626", bold = true }) -- Red
vim.api.nvim_set_hl(0, "TroubleHint", { fg = "#fca5a5", bg = "#dc2626", italic = true })
vim.api.nvim_set_hl(0, "GitStatusTitle", { fg = "#ffffff", bg = "#ca8a04", bold = true }) -- Yellow
vim.api.nvim_set_hl(0, "GitStatusHint", { fg = "#fef08a", bg = "#ca8a04", italic = true })
vim.api.nvim_set_hl(0, "BuffersTitle", { fg = "#ffffff", bg = "#16a34a", bold = true }) -- Green
vim.api.nvim_set_hl(0, "BuffersHint", { fg = "#bbf7d0", bg = "#16a34a", italic = true })
vim.api.nvim_set_hl(0, "SymbolsTitle", { fg = "#ffffff", bg = "#92400e", bold = true }) -- Brown
vim.api.nvim_set_hl(0, "SymbolsHint", { fg = "#fcd34d", bg = "#92400e", italic = true })

M.config = {
	height = 0.3, -- 30% of screen height
}

-- State tracks open order and drawer-specific data
M.state = {
	-- Ordered list of open drawer IDs (in open order, left-to-right)
	open_order = {}, -- e.g., {"primary", "trouble", "buffers"}

	-- Drawer-specific data
	drawers = {
		primary = { buf = nil, job_id = nil },
		secondary = { buf = nil, job_id = nil },
		trouble = {},
		gitstatus = {},
		buffers = {},
		symbols = {},
	},
}

-- Drawer metadata for winbars
local drawer_meta = {
	primary = { title = "Terminal Z", key = ",z", hl_title = "TerminalZTitle", hl_hint = "TerminalZHint" },
	secondary = { title = "Terminal X", key = ",x", hl_title = "TerminalXTitle", hl_hint = "TerminalXHint" },
	trouble = { title = "Trouble.nvim Diagnostics", key = ",t", hl_title = "TroubleTitle", hl_hint = "TroubleHint" },
	gitstatus = { title = "Git Status", key = ",s", hl_title = "GitStatusTitle", hl_hint = "GitStatusHint" },
	buffers = { title = "Buffers", key = ",b", hl_title = "BuffersTitle", hl_hint = "BuffersHint" },
	symbols = { title = "Document Symbols", key = ",d", hl_title = "SymbolsTitle", hl_hint = "SymbolsHint" },
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

-- Set winbar title for a drawer window
local function set_winbar(win, slot)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	local meta = drawer_meta[slot]
	if not meta then
		return
	end
	vim.wo[win].winbar = "%#"
		.. meta.hl_title
		.. "# "
		.. meta.title
		.. " %#"
		.. meta.hl_hint
		.. "#(type "
		.. meta.key
		.. " to toggle) %*"
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
		-- Trouble drawer
		elseif slot == "trouble" and vim.bo[buf].filetype == "trouble" then
			return win
		-- Neo-tree drawers (check buffer name for source)
		elseif vim.bo[buf].filetype == "neo-tree" then
			local bufname = vim.api.nvim_buf_get_name(buf)
			if slot == "gitstatus" and bufname:match("git_status") then
				return win
			elseif slot == "buffers" and bufname:match("buffers") then
				return win
			elseif slot == "symbols" and bufname:match("document_symbols") then
				return win
			end
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

-- Toggle trouble drawer (,t)
function M.toggle_trouble()
	local ok, trouble = pcall(require, "trouble")
	if not ok then
		vim.notify("trouble.nvim not installed", vim.log.levels.ERROR)
		return
	end

	if is_drawer_open("trouble") then
		trouble.close()
		remove_from_open_order("trouble")
		rebalance_drawers()
	else
		local open_wins = get_open_drawer_windows()

		if #open_wins == 0 then
			-- No drawers open, open trouble at bottom
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
		else
			-- Open trouble relative to rightmost drawer
			local rightmost = open_wins[#open_wins]
			vim.api.nvim_set_current_win(rightmost.win)
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
		end

		add_to_open_order("trouble")

		-- Apply winbar after trouble creates its window (with retry)
		local function apply_trouble_winbar(attempts)
			attempts = attempts or 0
			local win = find_drawer_window("trouble")
			if win then
				rebalance_drawers()
				return
			end
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

-- Toggle git status drawer (,s)
function M.toggle_gitstatus()
	if is_drawer_open("gitstatus") then
		vim.cmd("Neotree close source=git_status")
		remove_from_open_order("gitstatus")
		rebalance_drawers()
	else
		local open_wins = get_open_drawer_windows()

		if #open_wins == 0 then
			vim.cmd("Neotree source=git_status position=bottom action=show")
		else
			local rightmost = open_wins[#open_wins]
			vim.api.nvim_set_current_win(rightmost.win)
			vim.cmd("Neotree source=git_status position=right action=show")
		end

		add_to_open_order("gitstatus")

		-- Apply winbar after neo-tree creates its window (with retry)
		local function apply_winbar(attempts)
			attempts = attempts or 0
			local win = find_drawer_window("gitstatus")
			if win then
				rebalance_drawers()
				return
			end
			if attempts < 10 then
				vim.defer_fn(function()
					apply_winbar(attempts + 1)
				end, 10)
			end
		end

		vim.defer_fn(function()
			apply_winbar(0)
		end, 10)
	end
end

-- Toggle buffers drawer (,b)
function M.toggle_buffers()
	if is_drawer_open("buffers") then
		vim.cmd("Neotree close source=buffers")
		remove_from_open_order("buffers")
		rebalance_drawers()
	else
		local open_wins = get_open_drawer_windows()

		if #open_wins == 0 then
			vim.cmd("Neotree source=buffers position=bottom action=show")
		else
			local rightmost = open_wins[#open_wins]
			vim.api.nvim_set_current_win(rightmost.win)
			vim.cmd("Neotree source=buffers position=right action=show")
		end

		add_to_open_order("buffers")

		local function apply_winbar(attempts)
			attempts = attempts or 0
			local win = find_drawer_window("buffers")
			if win then
				rebalance_drawers()
				return
			end
			if attempts < 10 then
				vim.defer_fn(function()
					apply_winbar(attempts + 1)
				end, 10)
			end
		end

		vim.defer_fn(function()
			apply_winbar(0)
		end, 10)
	end
end

-- Toggle document symbols drawer (,d)
function M.toggle_symbols()
	if is_drawer_open("symbols") then
		vim.cmd("Neotree close source=document_symbols")
		remove_from_open_order("symbols")
		rebalance_drawers()
	else
		local open_wins = get_open_drawer_windows()

		if #open_wins == 0 then
			vim.cmd("Neotree source=document_symbols position=bottom action=show")
		else
			local rightmost = open_wins[#open_wins]
			vim.api.nvim_set_current_win(rightmost.win)
			vim.cmd("Neotree source=document_symbols position=right action=show")
		end

		add_to_open_order("symbols")

		local function apply_winbar(attempts)
			attempts = attempts or 0
			local win = find_drawer_window("symbols")
			if win then
				rebalance_drawers()
				return
			end
			if attempts < 10 then
				vim.defer_fn(function()
					apply_winbar(attempts + 1)
				end, 10)
			end
		end

		vim.defer_fn(function()
			apply_winbar(0)
		end, 10)
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
		if slot == "primary" or slot == "secondary" then
			local win = find_drawer_window(slot)
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, false)
			end
		elseif slot == "trouble" then
			local ok, trouble = pcall(require, "trouble")
			if ok then
				trouble.close()
			end
		elseif slot == "gitstatus" then
			vim.cmd("Neotree close source=git_status")
		elseif slot == "buffers" then
			vim.cmd("Neotree close source=buffers")
		elseif slot == "symbols" then
			vim.cmd("Neotree close source=document_symbols")
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
