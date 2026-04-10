-- Terminal title status for WezTerm tabs.
-- Shows one icon per managed Neovim terminal:
--   🤖 - claude or codex is running
--   🖥️ - some other program is running
--   💤 - terminal exists but shell is idle

local M = {}

vim.g._terminal_title_setup_done = vim.g._terminal_title_setup_done or false

local poll_timer = nil
local update_in_progress = false

local POLL_INTERVAL_MS = 1000
local ICON_IDLE = "💤"
local ICON_ACTIVE = "🖥️"
local ICON_AGENT = "🤖"

local AGENT_COMMANDS = {
	claude = true,
	codex = true,
}

local function set_terminal_title(title, force)
	if not force and title == vim.g._terminal_title_last then
		return
	end

	vim.g._terminal_title_last = title
	io.write("\x1b]2;" .. title .. "\x07")
	io.flush()
end

local function get_base_title()
	local cwd = vim.fn.getcwd()
	local title = vim.fn.fnamemodify(cwd, ":~")
	return title ~= "" and title or cwd
end

local function get_job_pid(job_id)
	if not job_id or job_id <= 0 then
		return nil
	end

	local ok, pid = pcall(vim.fn.jobpid, job_id)
	if not ok or not pid or pid <= 0 then
		return nil
	end

	return pid
end

local function get_terminal_sessions()
	local sessions = {}
	for _, session in ipairs(require("util.panes").list_terminal_sessions()) do
		local pid = get_job_pid(session.job_id)
		if pid then
			table.insert(sessions, { kind = session.kind, pid = pid })
		end
	end

	return sessions
end

local function normalize_command_name(command)
	local name = vim.trim(command or "")
	name = name:match("([^/]+)$") or name
	return name:lower()
end

local function classify_terminal_async(session, callback)
	vim.system({ "pgrep", "-P", tostring(session.pid) }, { text = true }, function(result)
		local children = result.stdout and vim.split(result.stdout, "\n", { trimempty = true }) or {}

		if #children == 0 then
			vim.schedule(function()
				callback(ICON_IDLE)
			end)
			return
		end

		vim.system({ "ps", "-o", "comm=", "-p", table.concat(children, ",") }, { text = true }, function(ps_result)
			local icon = ICON_ACTIVE
			local commands = ps_result.stdout and vim.split(ps_result.stdout, "\n", { trimempty = true }) or {}

			for _, command in ipairs(commands) do
				if AGENT_COMMANDS[normalize_command_name(command)] then
					icon = ICON_AGENT
					break
				end
			end

			vim.schedule(function()
				callback(icon)
			end)
		end)
	end)
end

local function detect_icons_async(callback)
	local sessions = get_terminal_sessions()
	if #sessions == 0 then
		callback({})
		return
	end

	local icons = {}
	local pending = #sessions

	for index, session in ipairs(sessions) do
		classify_terminal_async(session, function(icon)
			icons[index] = icon
			pending = pending - 1

			if pending <= 0 then
				callback(icons)
			end
		end)
	end
end

local function apply_title(icons)
	local base_title = get_base_title()
	local prefix = (#icons > 0) and (table.concat(icons, " ") .. " ") or ""
	set_terminal_title(prefix .. base_title, true)
end

function M._update_title()
	if update_in_progress then
		return
	end

	update_in_progress = true
	detect_icons_async(function(icons)
		update_in_progress = false
		apply_title(icons)
	end)
end

function M.force_update()
	M._update_title()
end

local function has_managed_terminals()
	return #get_terminal_sessions() > 0
end

local function refresh_polling_state()
	if has_managed_terminals() then
		M.start()
	else
		M.stop()
	end
end

function M.start()
	if poll_timer then
		return
	end

	poll_timer = vim.uv.new_timer()
	poll_timer:start(
		0,
		POLL_INTERVAL_MS,
		vim.schedule_wrap(function()
			pcall(M._update_title)
		end)
	)
end

function M.stop()
	if not poll_timer then
		return
	end

	poll_timer:stop()
	poll_timer:close()
	poll_timer = nil
end

function M.setup()
	if vim.g._terminal_title_setup_done then
		return M
	end

	vim.g._terminal_title_setup_done = true

	local group = vim.api.nvim_create_augroup("TerminalTitleStatus", { clear = true })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			M.stop()
			set_terminal_title(get_base_title(), true)
		end,
		desc = "Reset terminal title on exit",
	})

	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			M.force_update()
		end,
		desc = "Refresh terminal title when cwd changes",
	})

	vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufDelete", "BufWipeout" }, {
		group = group,
		callback = function()
			vim.defer_fn(function()
				refresh_polling_state()
				M.force_update()
			end, 50)
		end,
		desc = "Refresh terminal title when managed terminals change",
	})

	refresh_polling_state()
	M.force_update()
	return M
end

return M
