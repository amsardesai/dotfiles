-- WezTerm Configuration
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require("wezterm")
local config = {}

-- Use config builder for better error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Open links in Chrome instead of system default browser
wezterm.on("open-uri", function(window, pane, uri)
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
config.font = wezterm.font("CaskaydiaCove Nerd Font Propo", { weight = "Light" })
config.font_size = 14
config.line_height = 1

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
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500

-- =============================================================================
-- Aesthetics
-- =============================================================================

-- Transparency with blur (macOS)
config.window_background_opacity = 0.9
config.macos_window_background_blur = 40

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

-- Hyperlink detection (URLs, file paths, etc.)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Bypass mouse reporting for CMD key (allows CMD+Click links even in tmux/vim)
config.bypass_mouse_reporting_modifiers = "SUPER"

-- =============================================================================
-- Keybindings
-- =============================================================================

config.keys = {
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
}

-- =============================================================================
-- Mouse Bindings
-- =============================================================================

config.mouse_bindings = {
	-- CMD+Click opens hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Prevent Down event from interfering with link clicks
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.Nop,
	},
}

return config
