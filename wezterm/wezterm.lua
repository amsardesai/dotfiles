-- WezTerm Configuration
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require("wezterm")
local config = {}

-- Use config builder for better error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Helper: Extract filename from URI and check if it should open in editor
local function extract_edit_target(uri)
	-- Match our custom EDIT: scheme (see hyperlink_rules below)
	local target = uri:match("^EDIT:(.+)$")
	if target then
		return target
	end
	return nil
end

-- Handle hyperlink clicks (file paths → Neovim, URLs → Chrome)
wezterm.on("open-uri", function(window, pane, uri)
	-- Log for debugging (view with CTRL+SHIFT+L debug overlay)
	wezterm.log_info("open-uri: " .. uri)

	-- Handle our custom EDIT: scheme for file paths (with or without line:col)
	local target = extract_edit_target(uri)
	if target then
		wezterm.log_info("EDIT target: " .. target)

		-- Parse file:line:col, file:line, or just file
		local path, line, col = target:match("^(.+):(%d+):(%d+)$")
		if not path then
			path, line = target:match("^(.+):(%d+)$")
			col = "1"
		end
		if not path then
			-- No line number - just a path
			path = target
			line = "1"
			col = "1"
		end

		if path then
			-- Get pane's current working directory
			local cwd_uri = pane:get_current_working_dir()
			local cwd = cwd_uri and cwd_uri.file_path or os.getenv("HOME")
			local home = os.getenv("HOME")

			-- Expand ~ to home directory
			if path:match("^~/") then
				path = home .. path:sub(2)
			end

			local full_path = path:match("^/") and path or (cwd .. "/" .. path)

			-- Check if file exists
			local f = io.open(full_path, "r")
			if f then
				f:close()
				-- Open in Neovim via nvr - use pane-specific socket
				local pane_id = pane:pane_id()
				local nvim_socket = home .. "/.cache/nvim/server-" .. pane_id .. ".sock"
				wezterm.log_info("Opening: " .. full_path .. " at line " .. line)

				-- First, switch to a non-terminal window, then open the file
				-- wincmd p = go to previous window, wincmd w = cycle if that fails
				local vim_cmd = string.format(
					"if &buftype == 'terminal' | wincmd p | endif | edit +%s %s | call cursor(%s,%s)",
					line,
					full_path,
					line,
					col
				)

				local success, stdout, stderr = wezterm.run_child_process({
					"/opt/homebrew/bin/nvr",
					"--servername",
					nvim_socket,
					"--remote-send",
					string.format("<C-\\><C-n>:lua vim.schedule(function() vim.cmd([[%s]]) end)<CR>", vim_cmd),
				})
				if not success then
					wezterm.log_error("nvr failed: " .. (stderr or "unknown error"))
					window:toast_notification("WezTerm", "Failed to open in Neovim", nil, 3000)
				end
			else
				window:toast_notification("WezTerm", "File not found: " .. full_path, nil, 3000)
			end
		end
		return false
	end

	-- Default: open URLs in Chrome
	wezterm.open_with(uri, "Google Chrome")
	return false
end)

-- =============================================================================
-- Appearance
-- =============================================================================

-- Color scheme
-- Browse schemes at: https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = "tokyonight_night"

-- Font configuration
-- Load fonts from dotfiles repo (relative to this config file)
config.font_dirs = { "../fonts" }
config.font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Light" })
config.font_size = 14
config.line_height = 1

-- Font rules for specific styles
config.font_rules = {
	-- Italic: Light Italic
	{
		italic = true,
		intensity = "Normal",
		font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Light", italic = true }),
	},
	-- Bold: Bold weight
	{
		italic = false,
		intensity = "Bold",
		font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Bold" }),
	},
	-- Bold Italic: Bold Italic
	{
		italic = true,
		intensity = "Bold",
		font = wezterm.font("CaskaydiaCove Nerd Font", { weight = "Bold", italic = true }),
	},
}

-- Window appearance
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}
config.use_resize_increments = true
config.enable_scroll_bar = true

-- Hide scrollbar when in alt screen mode (Neovim uses alt screen, scrollbar is useless there)
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	overrides.enable_scroll_bar = not pane:is_alt_screen_active()
	window:set_config_overrides(overrides)
end)

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = true

-- Security
config.detect_password_input = true
config.window_close_confirmation = "AlwaysPrompt"

-- =============================================================================
-- Performance
-- =============================================================================

-- GPU acceleration
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- ProMotion display support (120Hz)
config.max_fps = 120
config.animation_fps = 120

-- Font rendering (crisper on Retina)
config.freetype_load_target = "Light"
config.freetype_load_flags = "NO_HINTING"

-- =============================================================================
-- Neovim Support
-- =============================================================================

-- macOS: Option key sends Alt/Meta instead of composing special characters
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Kitty keyboard protocol - better modifier key handling
config.enable_kitty_keyboard = true

-- CSI u encoding - distinguishes Ctrl+I from Tab, Ctrl+M from Enter, etc.
config.enable_csi_u_key_encoding = true

-- Better Unicode/emoji rendering
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"

-- Use wezterm terminfo for enhanced capabilities (undercurl, etc.)
config.term = "wezterm"

-- =============================================================================
-- Behavior
-- =============================================================================

-- Scrollback
config.scrollback_lines = 3500

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- =============================================================================
-- Aesthetics
-- =============================================================================

-- Transparency with blur (macOS) - DISABLED for performance during heavy terminal output
config.window_background_opacity = 1.0 -- No transparency (was 0.9)
config.macos_window_background_blur = 0 -- No blur (was 40)

-- Dim inactive panes for focus clarity
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.7,
}

-- =============================================================================
-- Quality of Life
-- =============================================================================

-- Disable audible bell, use visual flash instead
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- Hot reload config on save
config.automatically_reload_config = true

-- Native macOS fullscreen
config.native_macos_fullscreen_mode = true

-- Don't resize window when changing font size
config.adjust_window_size_when_changing_font_size = false

-- Better double-click word selection
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│"

-- Quick select patterns (CMD+SHIFT+Space to activate)
config.quick_select_patterns = {
	"[0-9a-f]{7,40}", -- Git commit hashes
	"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", -- UUIDs
}

-- Hyperlink detection - custom rules + defaults
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- File path charset: [\w./@\-] supports @ (path aliases like @/components)
-- Matches: src/file.ts:10, ./file.ts:10, @/components/Button.tsx:10
-- Excludes: file.ts:10, /file.ts:10 (no directory)

-- 1. Relative ./path or ../path WITH line:col
table.insert(config.hyperlink_rules, 1, {
	regex = [[(\.{1,2}/[\w./@\-]+\.\w+):(\d+):(\d+)\b]],
	format = "EDIT:$1:$2:$3",
})

-- 2. Directory path (src/...) or absolute (/System/...) WITH line:col
table.insert(config.hyperlink_rules, 2, {
	regex = [[([\w@\-]+/[\w./@\-]+\.\w+):(\d+):(\d+)\b]],
	format = "EDIT:$1:$2:$3",
})

-- 3. Relative ./path or ../path WITH line only
table.insert(config.hyperlink_rules, 3, {
	regex = [[(\.{1,2}/[\w./@\-]+\.\w+):(\d+)\b]],
	format = "EDIT:$1:$2",
})

-- 4. Directory path (src/...) or absolute (/System/...) WITH line only
table.insert(config.hyperlink_rules, 4, {
	regex = [[([\w@\-]+/[\w./@\-]+\.\w+):(\d+)\b]],
	format = "EDIT:$1:$2",
})

-- 5. Parenthesized paths (stack traces): (src/file.ts:10:5)
table.insert(config.hyperlink_rules, 5, {
	regex = [[\(([\w./@\-]+/[\w./@\-]+\.\w+):(\d+):(\d+)\)]],
	format = "EDIT:$1:$2:$3",
})

-- 6. Parenthesized paths WITH line only: (src/file.ts:10)
table.insert(config.hyperlink_rules, 6, {
	regex = [[\(([\w./@\-]+/[\w./@\-]+\.\w+):(\d+)\)]],
	format = "EDIT:$1:$2",
})

-- ============ Paths WITHOUT line numbers ============
-- These match file paths that don't have :line suffix
-- Requires directory component (slash) to avoid matching random words

-- 7. Absolute paths: /Users/ankit/.cache/nvim/server.sock
table.insert(config.hyperlink_rules, 7, {
	regex = [[(/[\w./@\-]+/[\w./@\-]+\.\w+)\b]],
	format = "EDIT:$1",
})

-- 8. Relative ./path or ../path: ./src/utils.ts, ../config.lua
table.insert(config.hyperlink_rules, 8, {
	regex = [[(\.{1,2}/[\w./@\-]+\.\w+)\b]],
	format = "EDIT:$1",
})

-- 9. Directory paths: src/utils.ts, @/components/Button.tsx
table.insert(config.hyperlink_rules, 9, {
	regex = [[([\w@\-]+/[\w./@\-]+\.\w+)\b]],
	format = "EDIT:$1",
})

-- 10. Tilde paths: ~/.cache/nvim/server.sock, ~/dotfiles/init.lua
table.insert(config.hyperlink_rules, 10, {
	regex = [[(~/[\w./@\-]+\.\w+)\b]],
	format = "EDIT:$1",
})

-- Bypass mouse reporting for CMD key (allows CMD+Click links even in tmux/vim)
config.bypass_mouse_reporting_modifiers = "SUPER"

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

local EXPAND_ICON = wezterm.nerdfonts.md_arrow_expand

wezterm.on("format-tab-title", function(tab, tabs, panes, _config, hover, max_width)
	local title = tab_title(tab)

	-- Check for zoomed pane
	local is_zoomed = false
	for _, pane in ipairs(tab.panes) do
		if pane.is_zoomed then
			is_zoomed = true
			break
		end
	end

	-- Check for unseen output
	local has_unseen_output = false
	for _, pane in ipairs(tab.panes) do
		if pane.has_unseen_output then
			has_unseen_output = true
			break
		end
	end

	-- Build the tab title
	local bg = tab.is_active and "#000" or "none"
	local fg = tab.is_active and "#eee" or (has_unseen_output and "#aaa" or "none")

	-- Slightly red background if zoomed
	if is_zoomed and tab.is_active then
		bg = "#300"
	end

	local result = {}
	if bg ~= "none" then
		table.insert(result, { Background = { Color = bg } })
	end
	if fg ~= "none" then
		table.insert(result, { Foreground = { Color = fg } })
	end
	table.insert(result, { Text = " " .. title })
	if is_zoomed then
		table.insert(result, { Foreground = { Color = "#f66" } })
		table.insert(result, { Text = "  " .. EXPAND_ICON })
	end
	table.insert(result, { Text = " " })

	return result
end)

-- =============================================================================
-- Keybindings
-- =============================================================================

config.keys = {
	-- Disable Cmd+Q to prevent accidental quit (use Cmd+W to close panes/windows)
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.Nop,
	},

	-- Split panes
	{
		key = "d",
		mods = "CMD",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Navigate panes
	{
		key = "LeftArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "UpArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "DownArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},

	-- Close pane
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	-- Create/close tabs
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},

	-- Navigate tabs
	{
		key = "[",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "]",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},

	-- Toggle pane zoom/maximize
	{
		key = "Return",
		mods = "CMD|SHIFT",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- Navigate tabs with arrow keys
	{
		key = "LeftArrow",
		mods = "CMD|ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "RightArrow",
		mods = "CMD|ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},

	-- Pane selection mode - lets you pick a pane to swap with
	{
		key = "s",
		mods = "CMD|SHIFT",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},

	-- Font size
	{
		key = "=",
		mods = "CMD",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CMD",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.ResetFontSize,
	},

	-- Quick select (select text patterns with keyboard)
	{
		key = "Space",
		mods = "CMD|SHIFT",
		action = wezterm.action.QuickSelect,
	},

	-- Search scrollback
	{
		key = "f",
		mods = "CMD",
		action = wezterm.action.Search({ CaseInSensitiveString = "" }),
	},

	-- Copy mode (vim-like scrollback navigation)
	{
		key = "x",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateCopyMode,
	},

	-- Clear scrollback
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
	},

	-- Reload config
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},

	-- Buffer navigation: Option-Shift-[ and Option-Shift-]
	-- Send F13/F14 escape sequences directly (ESC[25~ and ESC[26~)
	{
		key = "LeftBracket",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("\x1b[25~"),
	},
	{
		key = "RightBracket",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("\x1b[26~"),
	},
	-- Option-Shift-Enter for zoom (CSI u format: keycode 13, modifier 4 = Alt+Shift)
	{
		key = "Return",
		mods = "ALT|SHIFT",
		action = wezterm.action.SendString("\x1b[13;4u"),
	},
}

-- =============================================================================
-- Mouse Bindings
-- =============================================================================

config.mouse_bindings = {
	-- CMD+Click opens hyperlinks (triggers open-uri event)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Disable the down event so CMD+click works cleanly
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.Nop,
	},
}

return config
