-- Claude Code Status Indicator for WezTerm Tab Titles
-- Updates terminal title with emoji indicators based on Claude Code and LSP state:
--
-- AI Agent Status (left side, per-instance with superscript numbers):
--   ⚠️ - Stale connection (claudecode.nvim: no ping response for 30+ seconds)
--   ⏳ - Diff pending review (claudecode.nvim: openDiff tool waiting)
--   🔄 - Connecting (claudecode.nvim: WebSocket handshake in progress)
--   🤖 - Thinking (CPU > 2% - Claude is processing)
--   👤 - Idle (CPU ≤ 2% - user's turn)
--
-- LSP Status (right side, only shown when busy):
--   🔵 - LSP busy (processing/indexing)
--
-- Examples: "🤖 project" (1 instance), "🤖¹ ✏️² project 🔵" (2 instances, LSP busy)
-- Detects ALL Claude instances in current directory (including external terminals)
--
-- Performance: Uses async vim.system() calls to avoid blocking Neovim's main loop

local M = {}

-- Use vim.g for state so it persists across dofile() calls
vim.g._claude_status_setup_done = vim.g._claude_status_setup_done or false

-- Local state (doesn't need persistence)
local poll_timer = nil
local refresh_timer = nil
local POLL_INTERVAL_MS = 2000 -- Expensive detection: async ps/lsof every 2 seconds
local REFRESH_INTERVAL_MS = 200 -- Fast title refresh: re-apply cached title every 200ms
local STALE_THRESHOLD_MS = 30000 -- Consider connection stale after 30 seconds without pong
local CPU_THRESHOLD = 2 -- CPU > 2% = thinking

-- Cached state for async operations
local cached_instances = {}
local last_title = "" -- Cache to avoid redundant terminal writes
local async_in_progress = false

-- Unicode superscript numbers
local SUPERSCRIPTS = { "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹" }

-- Status to emoji mapping (AI agent status - shown on left)
local STATUS_EMOJI = {
	stale = "⚠️", -- Connection stale (highest priority - problem)
	diff_pending = "⏳", -- User action required: review diff
	connecting = "🔄", -- Handshake in progress
	thinking = "🤖", -- CPU active - Claude processing
	idle = "👤", -- CPU idle - user's turn
}

-- LSP status to emoji mapping (shown on right, only when busy)
local LSP_EMOJI = {
	busy = "🔵", -- LSP processing
}

-- =============================================================================
-- Process-Based Detection (Async - non-blocking)
-- =============================================================================

-- Async detection of Claude instances - calls callback(instances) when done
-- Uses vim.system() for non-blocking execution
local function detect_system_claude_instances_async(callback)
	if async_in_progress then
		-- Don't stack up async calls - use cached data
		callback(cached_instances)
		return
	end

	async_in_progress = true
	local cwd = vim.fn.getcwd()

	-- Step 1: Get all claude PIDs asynchronously
	vim.system(
		{ "sh", "-c", "ps -ax -o pid,comm | grep '[c]laude' | awk '{print $1}'" },
		{ text = true },
		function(ps_result)
			if ps_result.code ~= 0 or not ps_result.stdout then
				async_in_progress = false
				vim.schedule(function()
					callback({})
				end)
				return
			end

			local pids = vim.split(ps_result.stdout, "\n", { trimempty = true })
			if #pids == 0 then
				async_in_progress = false
				vim.schedule(function()
					callback({})
				end)
				return
			end

			-- Step 2: For each PID, get cwd and CPU usage in parallel
			local instances = {}
			local pending = #pids
			local completed = 0

			for _, pid in ipairs(pids) do
				-- Get working directory for this process
				vim.system(
					{ "sh", "-c", "lsof -p " .. pid .. " 2>/dev/null | grep cwd | awk '{print $NF}'" },
					{ text = true },
					function(lsof_result)
						local proc_cwd = lsof_result.stdout and vim.trim(lsof_result.stdout) or ""

						if proc_cwd == cwd then
							-- Get CPU usage for matching process
							vim.system(
								{ "sh", "-c", "ps -p " .. pid .. " -o %cpu= 2>/dev/null" },
								{ text = true },
								function(cpu_result)
									local cpu = tonumber(vim.trim(cpu_result.stdout or "0")) or 0
									local status = cpu > CPU_THRESHOLD and "thinking" or "idle"
									table.insert(instances, { pid = tonumber(pid), cpu = cpu, status = status })

									completed = completed + 1
									if completed >= pending then
										-- All done - sort and callback
										table.sort(instances, function(a, b)
											return a.pid < b.pid
										end)
										async_in_progress = false
										vim.schedule(function()
											callback(instances)
										end)
									end
								end
							)
						else
							-- Process not in our cwd - skip
							completed = completed + 1
							if completed >= pending then
								table.sort(instances, function(a, b)
									return a.pid < b.pid
								end)
								async_in_progress = false
								vim.schedule(function()
									callback(instances)
								end)
							end
						end
					end
				)
			end
		end
	)
end

-- Synchronous version for public API (M.get_status) - still needed for debugging
local function detect_system_claude_instances_sync()
	local cwd = vim.fn.getcwd()
	local instances = {}

	local ps_result = vim.fn.system("ps -ax -o pid,comm | grep '[c]laude' | awk '{print $1}'")
	local pids = vim.split(ps_result, "\n", { trimempty = true })

	if #pids == 0 then
		return instances
	end

	for _, pid in ipairs(pids) do
		local lsof_result = vim.fn.system("lsof -p " .. pid .. " 2>/dev/null | grep cwd")
		local proc_cwd = vim.trim(lsof_result):match("%S+$")

		if proc_cwd == cwd then
			local cpu_result = vim.fn.system("ps -p " .. pid .. " -o %cpu= 2>/dev/null")
			local cpu = tonumber(vim.trim(cpu_result)) or 0
			local status = cpu > CPU_THRESHOLD and "thinking" or "idle"
			table.insert(instances, { pid = tonumber(pid), cpu = cpu, status = status })
		end
	end

	table.sort(instances, function(a, b)
		return a.pid < b.pid
	end)

	return instances
end

-- =============================================================================
-- claudecode.nvim State Overrides (for connected instances only)
-- =============================================================================

-- Get list of clients from claudecode.nvim server status
local function get_claudecode_clients()
	local ok, server = pcall(require, "claudecode.server.init")
	if not ok then
		return {}
	end
	local status = server.get_status()
	return status.clients or {}
end

-- Check if any claudecode.nvim connection is stale
local function is_any_stale()
	local clients = get_claudecode_clients()
	if #clients == 0 then
		return false
	end

	local now = vim.uv.now()
	for _, client in ipairs(clients) do
		if client.last_pong and (now - client.last_pong) > STALE_THRESHOLD_MS then
			return true
		end
	end
	return false
end

-- Check if any claudecode.nvim client is still connecting
local function is_any_connecting()
	local clients = get_claudecode_clients()
	for _, client in ipairs(clients) do
		if client.state == "connecting" or client.handshake_complete == false then
			return true
		end
	end
	return false
end

-- Check if diff is pending review (claudecode.nvim deferred response)
local function has_diff_pending()
	return _G.claude_deferred_responses and next(_G.claude_deferred_responses) ~= nil
end

-- =============================================================================
-- LSP Status Detection
-- =============================================================================

-- Get LSP status for entire Neovim instance
-- Returns: "busy" if any LSP is processing, "ready" if idle, nil if no LSPs attached
local function get_lsp_status()
	-- Check if any LSP clients are attached (across all buffers)
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		return nil
	end

	-- Check if any LSP has active progress (vim.lsp.status returns progress message)
	local status = vim.lsp.status()
	if status and status ~= "" then
		return "busy"
	end

	return "ready"
end

-- Build LSP suffix for title (only shows when busy)
local function build_lsp_suffix()
	local lsp_status = get_lsp_status()
	if lsp_status == "busy" then
		return " " .. LSP_EMOJI.busy
	end
	return ""
end

-- =============================================================================
-- Title Building
-- =============================================================================

-- Get base title from current working directory
local function get_base_title()
	local cwd = vim.fn.getcwd()
	local base = vim.fn.fnamemodify(cwd, ":t")
	if base == "" then
		base = "nvim"
	end
	return base
end

-- Build emoji prefix from instance list
-- Each instance gets its own numbered emoji based on its status
local function build_prefix(instances, override_status)
	if #instances == 0 then
		return ""
	end

	local emojis = {}
	for i, instance in ipairs(instances) do
		-- Apply override status to first instance if present
		local status = instance.status
		if i == 1 and override_status then
			status = override_status
		end

		local emoji = STATUS_EMOJI[status] or STATUS_EMOJI.idle
		-- Only show superscript numbers when there are multiple instances
		if #instances > 1 then
			local superscript = SUPERSCRIPTS[i] or tostring(i)
			table.insert(emojis, emoji .. superscript)
		else
			table.insert(emojis, emoji)
		end
	end

	return table.concat(emojis, " ") .. " "
end

-- =============================================================================
-- Terminal Title Control
-- =============================================================================

-- Emit OSC 2 sequence to set terminal title
-- force=true bypasses cache check (for refresh timer to combat external title overwrites)
local function set_terminal_title(title, force)
	-- Skip if unchanged (unless forced)
	if not force and title == last_title then
		return
	end
	last_title = title

	-- OSC 2 sets window/tab title - read by WezTerm for tab title
	io.write("\x1b]2;" .. title .. "\x07")
	io.flush()
end

-- Build and set title from current state (uses cached instances)
local function apply_title(instances)
	-- Determine override status from claudecode.nvim (highest priority states)
	local override_status = nil
	if is_any_stale() then
		override_status = "stale"
	elseif has_diff_pending() then
		override_status = "diff_pending"
	elseif is_any_connecting() then
		override_status = "connecting"
	end

	local base_title = get_base_title()
	local prefix = build_prefix(instances, override_status)
	local suffix = build_lsp_suffix()
	local title = prefix .. base_title .. suffix

	set_terminal_title(title)
end

-- Update terminal title based on current status (async)
-- Called by detection timer (2s) - runs expensive process detection
function M._update_title()
	-- Trigger async detection - will update title when complete
	detect_system_claude_instances_async(function(instances)
		cached_instances = instances
		apply_title(instances)
	end)
end

-- Refresh title from cache (no process detection)
-- Called by refresh timer (200ms) - cheap, always writes to combat external overwrites
function M._refresh_title()
	-- Determine override status from claudecode.nvim (highest priority states)
	local override_status = nil
	if is_any_stale() then
		override_status = "stale"
	elseif has_diff_pending() then
		override_status = "diff_pending"
	elseif is_any_connecting() then
		override_status = "connecting"
	end

	local base_title = get_base_title()
	local prefix = build_prefix(cached_instances, override_status)
	local suffix = build_lsp_suffix()
	local title = prefix .. base_title .. suffix

	-- Force write to combat external title overwrites (WezTerm focus events, etc.)
	set_terminal_title(title, true)
end

-- =============================================================================
-- Public API
-- =============================================================================

-- Get current status info (for debugging/statusline)
-- Note: Uses synchronous calls - don't call frequently
-- Returns: instances array, override_status (or nil), lsp_status (or nil)
function M.get_status()
	local instances = detect_system_claude_instances_sync()

	local override_status = nil
	if is_any_stale() then
		override_status = "stale"
	elseif has_diff_pending() then
		override_status = "diff_pending"
	elseif is_any_connecting() then
		override_status = "connecting"
	end

	local lsp_status = get_lsp_status()

	return instances, override_status, lsp_status
end

-- Force immediate title update
function M.force_update()
	M._update_title()
end

-- Start both timers (detection + refresh)
function M.start()
	if poll_timer then
		return
	end

	-- Detection timer: expensive async process detection every 2s
	poll_timer = vim.uv.new_timer()
	poll_timer:start(
		0,
		POLL_INTERVAL_MS,
		vim.schedule_wrap(function()
			pcall(M._update_title)
		end)
	)

	-- Refresh timer: cheap title re-apply every 200ms to combat external overwrites
	refresh_timer = vim.uv.new_timer()
	refresh_timer:start(
		100, -- Start after 100ms (let detection run first)
		REFRESH_INTERVAL_MS,
		vim.schedule_wrap(function()
			pcall(M._refresh_title)
		end)
	)
end

-- Stop both timers
function M.stop()
	if poll_timer then
		poll_timer:stop()
		poll_timer:close()
		poll_timer = nil
	end
	if refresh_timer then
		refresh_timer:stop()
		refresh_timer:close()
		refresh_timer = nil
	end
end

-- Initialize module (idempotent)
function M.setup()
	if vim.g._claude_status_setup_done then
		return M
	end
	vim.g._claude_status_setup_done = true

	M.start()

	-- Create autocommand group
	local group = vim.api.nvim_create_augroup("ClaudeStatusIndicator", { clear = true })

	-- Reset title on exit (remove emoji prefix)
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			M.stop()
			set_terminal_title(get_base_title())
		end,
		desc = "Clean up Claude status indicator on exit",
	})

	-- Update on directory change
	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			M.force_update()
		end,
		desc = "Update Claude status on directory change",
	})

	return M
end

return M
