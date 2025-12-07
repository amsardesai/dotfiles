-- File cache for instant file picker (persisted across sessions)
-- Provides fast file listing by caching git ls-files results to disk

local M = {}

-- Use vim.g for state so it persists across dofile() calls
vim.g._file_cache = vim.g._file_cache or {}
vim.g._file_cache_job = vim.g._file_cache_job or nil
vim.g._file_cache_mtime = vim.g._file_cache_mtime or nil
vim.g._file_cache_setup_done = vim.g._file_cache_setup_done or false

local cache_dir = vim.fn.stdpath("cache") .. "/fzf_file_cache"
local git_watchers = {}

-- Get git index path for current repo
local function get_git_index_path()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
	if git_root and git_root ~= "" then
		return git_root .. "/.git/index"
	end
	return nil
end

-- Get .git/index mtime (changes on commits, staging, checkouts)
local function get_index_mtime()
	local index_path = get_git_index_path()
	if index_path then
		local stat = vim.uv.fs_stat(index_path)
		if stat then
			return stat.mtime.sec
		end
	end
	return nil
end

-- Accessors for global state
local function get_cache()
	local cache = vim.g._file_cache
	if cache and #cache > 0 then
		return cache
	end
	return nil
end

local function set_cache(files)
	vim.g._file_cache = files or {}
end

local function get_cached_mtime()
	return vim.g._file_cache_mtime
end

local function set_cached_mtime(mtime)
	vim.g._file_cache_mtime = mtime
end

-- Get cache file path based on git root (or cwd)
local function get_cache_path()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
	local project_id
	if git_root and git_root ~= "" then
		project_id = git_root:gsub("/", "%%")
	else
		project_id = vim.fn.getcwd():gsub("/", "%%")
	end
	return cache_dir .. "/" .. project_id
end

-- Load cache from disk (instant)
local function load_cache_from_disk()
	local cache_path = get_cache_path()
	local files_path = cache_path .. ".txt"
	local mtime_path = cache_path .. ".mtime"

	if vim.uv.fs_stat(files_path) then
		local lines = vim.fn.readfile(files_path)
		if #lines > 0 then
			set_cache(lines)
			-- Load saved mtime
			if vim.uv.fs_stat(mtime_path) then
				local mtime_lines = vim.fn.readfile(mtime_path)
				if #mtime_lines > 0 then
					set_cached_mtime(tonumber(mtime_lines[1]))
				end
			end
			return true
		end
	end
	return false
end

-- Save cache to disk
local function save_cache_to_disk()
	local cache = get_cache()
	if cache and #cache > 0 then
		vim.fn.mkdir(cache_dir, "p")
		local cache_path = get_cache_path()
		vim.fn.writefile(cache, cache_path .. ".txt")
		-- Save current mtime
		local mtime = get_index_mtime()
		if mtime then
			vim.fn.writefile({ tostring(mtime) }, cache_path .. ".mtime")
			set_cached_mtime(mtime)
		end
	end
end

-- Check if cache needs refresh based on .git/index mtime
local function cache_needs_refresh()
	local current_mtime = get_index_mtime()
	if not current_mtime then
		return true -- Not a git repo, always refresh
	end
	local cached_mtime = get_cached_mtime()
	if not cached_mtime then
		return true -- No cached mtime, need refresh
	end
	return current_mtime ~= cached_mtime
end

-- Refresh the file cache
function M.refresh(force)
	-- Skip if cache is fresh (unless forced)
	if not force and get_cache() and not cache_needs_refresh() then
		return
	end

	-- Cancel any in-progress refresh
	if vim.g._file_cache_job then
		pcall(vim.fn.jobstop, vim.g._file_cache_job)
	end

	vim.g._file_cache_job = vim.fn.jobstart("git ls-files --cached --others --exclude-standard", {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				local files = vim.tbl_filter(function(l)
					return l ~= ""
				end, data)
				set_cache(files)
				-- Persist to disk after refresh
				save_cache_to_disk()
			end
		end,
		on_exit = function()
			vim.g._file_cache_job = nil
		end,
	})
end

-- Force refresh (bypasses mtime check)
function M.force_refresh()
	set_cache(nil)
	set_cached_mtime(nil)
	M.refresh(true)
	vim.notify("File cache refreshing...", vim.log.levels.INFO)
end

-- Get the cached file list
function M.get()
	return get_cache()
end

-- Load cache from disk
function M.load()
	return load_cache_from_disk()
end

-- Setup git watchers for automatic refresh
local function setup_git_watchers()
	-- Clean up existing watchers
	for _, watcher in ipairs(git_watchers) do
		watcher:stop()
	end
	git_watchers = {}

	local cwd = vim.fn.getcwd()
	local git_entry = cwd .. "/.git"

	-- Check if .git exists
	local stat = vim.uv.fs_stat(git_entry)
	if not stat then
		return
	end

	local git_dir

	-- Handle worktrees: .git is a file containing "gitdir: /path/to/git/dir"
	if stat.type == "file" then
		local content = vim.fn.readfile(git_entry)[1] or ""
		local gitdir = content:match("gitdir: (.+)")
		if not gitdir then
			return
		end

		-- Resolve relative paths
		if not gitdir:match("^/") then
			gitdir = vim.fn.fnamemodify(cwd .. "/" .. gitdir, ":p")
		end
		git_dir = gitdir:gsub("/$", "") .. "/"
	else
		git_dir = git_entry .. "/"
	end

	local debounce_timer = nil

	local function debounced_refresh()
		if debounce_timer then
			debounce_timer:stop()
		end
		debounce_timer = vim.defer_fn(M.refresh, 200)
	end

	-- Watch HEAD and index
	for _, file in ipairs({ "HEAD", "index" }) do
		local filepath = git_dir .. file
		if vim.uv.fs_stat(filepath) then
			local watcher = vim.uv.new_fs_event()
			watcher:start(filepath, {}, vim.schedule_wrap(debounced_refresh))
			table.insert(git_watchers, watcher)
		end
	end
end

-- Initialize the cache system (call once on startup)
function M.setup()
	-- Idempotent: only setup once
	if vim.g._file_cache_setup_done then
		return
	end
	vim.g._file_cache_setup_done = true

	-- Function to do the actual initialization
	local function do_init()
		local loaded = load_cache_from_disk()
		if not loaded then
			vim.notify("Building file cache for the first time...", vim.log.levels.INFO)
		end
		-- Refresh in background after short delay
		vim.defer_fn(M.refresh, 500)
		-- Setup git watchers
		setup_git_watchers()
	end

	-- If VimEnter already happened, init immediately
	if vim.v.vim_did_enter == 1 then
		do_init()
	else
		-- Otherwise, wait for VimEnter
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = do_init,
			once = true,
		})
	end

	-- Refresh on directory change (load from disk first, then refresh, setup watchers)
	vim.api.nvim_create_autocmd("DirChanged", {
		callback = function()
			load_cache_from_disk()
			M.refresh()
			setup_git_watchers()
		end,
	})

	-- Refresh periodically (every 60s) for external changes
	local cache_timer = vim.uv.new_timer()
	cache_timer:start(60000, 60000, vim.schedule_wrap(M.refresh))
end

return M
