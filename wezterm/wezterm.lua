-- WezTerm Configuration
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require 'wezterm'
local config = {}

-- Use config builder for better error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- =============================================================================
-- Appearance
-- =============================================================================

-- Color scheme
-- Browse schemes at: https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Dracula'

-- Font configuration
config.font = wezterm.font('FantasqueSansM Nerd Font Mono', { weight = 'Regular' })
config.font_size = 15.0

-- Window appearance
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}
config.use_resize_increments = true
-- config.integrated_title_buttons = { 'Close' }

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- =============================================================================
-- Behavior
-- =============================================================================

-- Scrollback
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- Cursor movement easing (subtle animation)
config.animation_fps = 60

-- =============================================================================
-- Keybindings
-- =============================================================================

config.keys = {
  -- Split panes
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Navigate panes
  {
    key = 'LeftArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },

  -- Close pane
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- Create/close tabs
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Navigate tabs
  {
    key = '[',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = ']',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateTabRelative(1),
  },

  -- Toggle pane zoom/maximize
  {
    key = 'Return',
    mods = 'CMD|SHIFT',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Navigate tabs with arrow keys
  {
    key = 'LeftArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'RightArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivateTabRelative(1),
  },

  -- Pane selection mode - lets you pick a pane to swap with
  {
    key = 's',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
}

-- =============================================================================
-- Additional Configuration
-- =============================================================================

-- Uncomment to enable more features:

-- Mouse bindings
-- config.mouse_bindings = { ... }

-- Advanced font configuration
-- config.font_rules = { ... }

-- Custom color overrides
-- config.colors = { ... }

-- Launch menu (useful for multiple shells/environments)
-- config.launch_menu = { ... }

return config
