-- Pane orchestration facade for managed Neovim panels.
-- This preserves the current pane backends while centralizing the public API.

local M = {}

local function has_ui()
	return #vim.api.nvim_list_uis() > 0
end

local function get_startup_context(data)
	local argc = vim.fn.argc()
	local is_directory = argc == 1 and vim.fn.isdirectory(data.file) == 1

	return {
		argc = argc,
		is_directory = is_directory,
		should_open = argc == 0 or is_directory,
		dir = is_directory and vim.fn.fnamemodify(data.file, ":p") or nil,
	}
end

local function get_agent_terminal()
	return _G._agent_terminal
end

local function set_agent_terminal(term)
	_G._agent_terminal = term
	return term
end

function M.toggle_agent()
	require("lazy").load({ plugins = { "snacks.nvim" } })

	local term = require("snacks").terminal.toggle(nil, {
		id = "agent",
		win = {
			position = "right",
			width = function()
				return math.min(math.floor(vim.o.columns * 0.40), 75)
			end,
			wo = {
				winbar = "%{%v:lua._agent_terminal_winbar()%}",
				winhighlight = "WinBar:AgentTitle,WinBarNC:AgentTitleNC",
				number = false,
				relativenumber = false,
			},
		},
	})

	return set_agent_terminal(term)
end

function M.hide_agent()
	local term = get_agent_terminal()
	if term then
		term:hide()
	end
end

function M.close_agent()
	local term = get_agent_terminal()
	if term then
		term:close()
		set_agent_terminal(nil)
	end
end

function M.toggle_drawer(slot)
	local drawers = require("util.bottom_drawers")
	if slot == "primary" then
		drawers.toggle_primary()
	elseif slot == "secondary" then
		drawers.toggle_secondary()
	end
end

function M.hide_all()
	require("util.bottom_drawers").hide_all()
	pcall(vim.cmd, "Neotree close")
	M.hide_agent()
end

function M.close_all()
	require("util.bottom_drawers").close_all()
	pcall(vim.cmd, "Neotree close")
	M.close_agent()
end

function M.list_terminal_sessions()
	local sessions = {}
	local term = get_agent_terminal()

	if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
		local channel = vim.bo[term.buf].channel
		if channel and channel > 0 then
			table.insert(sessions, { kind = "agent", job_id = channel, buf = term.buf })
		end
	end

	local drawers = package.loaded["util.bottom_drawers"]
	if drawers and drawers.state and drawers.state.drawers then
		for _, slot in ipairs({ "primary", "secondary" }) do
			local state = drawers.state.drawers[slot]
			if state and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
				table.insert(sessions, {
					kind = slot,
					job_id = state.job_id,
					buf = state.buf,
				})
			end
		end
	end

	return sessions
end

function M.startup_agent(data)
	if not has_ui() then
		return
	end

	local ctx = get_startup_context(data)
	if not ctx.should_open then
		return
	end

	vim.defer_fn(function()
		M.toggle_agent()

		-- Focus the rightmost pane (the agent terminal) after opening.
		vim.defer_fn(function()
			local max_col, target_win = -1, nil
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_is_valid(win) then
					local col = vim.api.nvim_win_get_position(win)[2]
					if col > max_col then
						max_col, target_win = col, win
					end
				end
			end
			if target_win then
				vim.api.nvim_set_current_win(target_win)
				vim.cmd("startinsert")
			end
		end, 100)
	end, 100)
end

function M.startup_tree(data)
	if not has_ui() then
		return
	end

	local ctx = get_startup_context(data)
	if not ctx.should_open then
		return
	end

	require("lazy").load({ plugins = { "neo-tree.nvim" } })

	-- Replace the initial netrw directory buffer before opening Neo-tree
	-- so `nvim <dir>` doesn't leave netrw visible.
	if ctx.is_directory then
		local initial_buf = vim.api.nvim_get_current_buf()
		vim.cmd("enew")
		pcall(vim.api.nvim_buf_delete, initial_buf, { force = true })
	end

	if ctx.dir then
		vim.cmd("Neotree action=show dir=" .. vim.fn.fnameescape(ctx.dir))
	else
		vim.cmd("Neotree action=show")
	end
end

return M
