# Dotfiles Repository - AI Context & Living Documentation

> **IMPORTANT INSTRUCTIONS FOR CLAUDE:**
>
> This file contains AI-specific context about the repository structure, patterns, and mental models.
> As you work with this codebase, you MUST automatically update this documentation when you discover:
>
> - **Architecture discoveries** - patterns, design decisions, how systems connect
> - **Key file/directory mappings** - where specific functionality lives
> - **Development workflows** - how changes are made, tested, deployed
> - **Tech stack changes** - new dependencies, tooling updates
> - **Important conventions** - naming patterns, code organization rules
>
> **Update behavior:** Be proactive and automatic. When you learn something significant, immediately update the appropriate section below. Create new sections if needed. Add timestamped entries to "Recent Discoveries" for items that don't fit existing sections.
>
> **Documentation split:**
>
> - This file (CLAUDE.md) → AI context, mental models, where things are, internal patterns
> - README.md → Human-facing docs, setup instructions, user-facing features
>
> Keep this documentation concise but informative. Future Claude instances rely on this!

---

## Repository Overview

**Purpose:** Personal dotfiles repository containing shell, vim/neovim, tmux, kitty, and git configurations. Optimized for web development with comprehensive LSP support, git workflows, and productivity shortcuts.

**Owner:** Ankit Sardesai - Software engineer at Notion working on web performance, accessibility, and developer experience.

**Core functionality:**

- Automated setup/teardown scripts that symlink configs to home directory
- Unified vim/neovim configuration with dual plugin ecosystems
- Shell environment with 50+ git aliases and productivity shortcuts
- Modern terminal setup (kitty/wezterm + tmux) with vi-mode

---

## Architecture & Patterns

### Configuration Strategy

- **Symlink-based:** All configs symlinked from `~/.dotfiles/` to standard locations (`~/.vimrc`, `~/.config/nvim/`, etc.)
- **Version controlled:** Entire dotfiles folder is a git repo for easy sync across devices
- **CRITICAL - Idempotent scripts:** `setup.sh` and `clean.sh` MUST be fully idempotent. Running them 1 time or 1000 times MUST produce identical results. See `setup.sh` header for implementation rules. Key patterns:
  - Check if work is needed before making changes
  - Use `grep -Fq` (substring match), NOT `grep -Fxq` (whole line match) when checking file contents
  - Use `ln -sfn` (force, no-deref) for symlinks
  - Use `mkdir -p` for directories

### Editor Philosophy

**Vim and Neovim are distinct configurations** - they are NOT trying to share code:

- **Neovim:** Full Lua-first stack with **lazy.nvim**, modern plugins, native LSP
  - Entry: `nvim/init.lua` → bootstraps lazy.nvim → `nvim/plugins/*.lua` → `vimconfig/main.vim` (options only) → `nvim/config/*.lua`
  - Plugins: fzf-lua, treesitter, native LSP, snacks.nvim, typescript-tools
  - All keymaps in Lua: `nvim/config/keymaps.lua`

- **Vim:** VimScript-based with **vim-plug**, async alternatives
  - Entry: `init-vim.vim` → `vimconfig/main.vim` (full)
  - Plugins: CtrlP, vim-lsp, NERDTree, nerdcommenter, vim-airline
  - All keymaps in VimScript: `vimconfig/mappings.vim`

- **Minimal sharing:** Only `vimconfig/options.vim` (basic vim options) and `ftplugin/*.vim` (filetype settings) are used by both

### Shell Environment Design

- **Layered sourcing:** `.zshrc`/`.bash_profile` source `.profile` which loads modular configs
- **Safety first:** All destructive commands aliased with `-i` flag (interactive prompts)
- **Git-centric:** Extensive git aliases optimized for modern workflows (rebase, cherry-pick, stash)

---

## Key Files & Directories

### Entry Points & Core Scripts

- `setup.sh` - Main installation script (downloads deps, creates symlinks, updates shell configs)
- `clean.sh` - Uninstallation script (removes symlinks, cleans git completion files)
- `.profile` - Main shell configuration sourced by both bash and zsh
- `.zshrc` - Zsh-specific configuration (git aliases, oh-my-zsh integration)
- `.lesskey` - Less pager configuration (env vars + keybindings)

### Editor Configurations

- `init-vim.vim` - Vim entry point (~/.vimrc symlink target)
- `nvim/init.lua` - Neovim entry point (~/.config/nvim/init.lua symlink target)
- `init-gvim.vim` - GUI vim settings (~/.gvimrc symlink target)
- `vimconfig/` - VimScript configuration (primarily for Vim, options shared with Neovim)
  - `vimconfig/main.vim` - Entry point (sources install, plugins, options, mappings)
  - `vimconfig/plugins.vim` - Vim-only plugin declarations (vim-plug)
  - `vimconfig/options.vim` - Vim options (shared with Neovim)
  - `vimconfig/mappings.vim` - **Vim-only** keymaps (Neovim uses `nvim/config/keymaps.lua`)
  - `vimconfig/helpers/behave_zz.vim` - Helper for zz behavior
- `nvim/` - Neovim-specific Lua configuration (symlinked to ~/.config/nvim/nvim/)
  - `nvim/plugins/` - Plugin specs for lazy.nvim (LazyVim-style organization)
    - `init.lua` - Entry point, combines all category files
    - `ui.lua` - Theme, lualine, bufferline, snacks, gitsigns, neominimap
    - `editor.lua` - nvim-tree, fzf-lua, flash, surround, comment, visual-multi
    - `lsp.lua` - lspconfig, mason, cmp, none-ls, lsp-lens, autopairs
    - `lang.lua` - treesitter, typescript-tools, filetype plugins
    - `tools.lua` - claudecode, image.nvim
  - `nvim/config/` - Global Neovim settings
    - `options.lua` - vim.g, vim.o settings (netrw disable, equalalways)
    - `keymaps.lua` - Global keymaps (buffer nav, diagnostics, context menu)
  - `nvim/util/` - Utility modules
    - `file_cache.lua` - Persisted file cache for instant file picker
    - `context_menu.lua` - Right-click context menu (uses fzf-lua)
    - `bottom_drawers.lua` - Dynamic bottom drawer system for terminals and panels
- `ftplugin/` - Filetype-specific settings (symlinked to both ~/.vim/ and ~/.config/nvim/)
  - `ftplugin/markdown.vim` - Soft wrapping, display-line navigation

### Terminal & Multiplexer

- `.tmux.conf` - Tmux configuration (Ctrl+A prefix, vi-mode, mouse support)
- `kitty.conf` - Kitty terminal emulator config (2,800+ lines: fonts, colors, shortcuts)
- `wezterm/` - WezTerm configuration directory (entire dir symlinked to ~/.config/wezterm)
- `.inputrc` - Readline configuration for terminal input

### Git Tooling

- `.gitconfig` - Main git configuration (delta pager, merge settings, fetch prune)
- `themes.gitconfig` - Delta theme configuration (gruvmax-fang Gruvbox theme)
- `git-completion.bash`, `git-completion.zsh`, `git-prompt.bash` - Downloaded by setup.sh (git-ignored)
- `.tern-config` - Tern (JavaScript tooling) configuration

---

## Tech Stack & Dependencies

### Required

- **Git** - Version control
- **Node.js & npm** - For LSP servers (see `npm-global-packages.txt`)
  - `typescript-language-server`, `typescript`
  - `vscode-langservers-extracted` (HTML/CSS/JSON/ESLint)
  - `vim-language-server`

### Brewfile (macOS)

`Brewfile` provides declarative dependency management. Run `brew bundle` to install all:

- **Core:** git, neovim, tmux, node
- **Terminal enhancements:** bat, fd, fzf, git-delta, ripgrep
- **Neovim deps:** imagemagick (for image.nvim)
- **Linters:** shellcheck, tflint
- **GUI apps:** wezterm

### Recommended

- **Zsh** with oh-my-zsh - Primary shell experience
- **Neovim** - Primary editor (Vim as fallback)
- **Tmux** - Terminal multiplexer
- **Kitty** or **WezTerm** - Terminal emulator (choose one or both)
- **bat** - Syntax-highlighted cat (used by fzf-lua previewer)
- **fd** - Fast file finder (fzf-lua fallback for non-git dirs)
- **ripgrep** - Fast grep (used by fzf-lua live grep)

### Optional Tools

- **Graphite CLI** - Enhanced git workflow
- **LM Studio CLI** - Local LLM integration
- **1Password CLI** - Password management

### Mason-managed Tools (auto-installed)

**LSP servers:** cssls, docker_compose_language_service, dockerls, eslint, html, jsonls, lua_ls, pylsp, terraformls, vimls, yamlls

**Linters/Formatters (via none-ls):** actionlint, biome, eslint_d, hadolint, markdownlint, prettier, shellcheck, shfmt, stylua, tflint, yamllint

### Plugin Managers

- **lazy.nvim** - Neovim plugin management (Lua-based, lazy-loading, 37ms startup)
- **vim-plug** - Vim plugin management (auto-installs on first launch)
- **TPM (Tmux Plugin Manager)** - Tmux plugin management
- **oh-my-zsh** - Zsh plugin framework (if installed)
- **Mason** - LSP/linter/formatter installer for Neovim

---

## Development Workflows & Conventions

### Setup on New Machine

1. Clone repo to `~/.dotfiles`
2. Run `./setup.sh` (downloads deps, creates symlinks, updates shell configs)
3. Restart shell with `exec $SHELL`
4. Open nvim (plugins auto-install via vim-plug)

### Making Configuration Changes

1. Edit files directly in `~/.dotfiles/` (changes immediately reflected via symlinks)
2. Test changes (reload shell with `rebash`, reload vim/neovim with `,r`)
3. Commit and push changes
4. On other devices: `cd ~/.dotfiles && git pull`

### Common Operations

- **Update plugins:**
  - Neovim: `:Lazy update` (or `:Lazy` to open UI)
  - Vim: `:PlugUpdate`
- **Reload configs:** `rebash` (shell), `,r` (vim/neovim), `Ctrl+A :source-file ~/.tmux.conf` (tmux)
- **Clean install:** Run `./clean.sh` then `./setup.sh`

---

## Recent Discoveries

### 2025-12-19 (Latest)

#### Session Persistence (persistence.nvim)

Added automatic session save/restore for directory-based workflows.

**File:** `nvim/plugins/editor.lua`

**Behavior:**
- `nvim .` or `nvim` (no args) → auto-restores previous session (open buffers)
- `nvim file.txt` → opens only that file, no session restore
- `:qa` → saves session on quit
- `:qa!` → does NOT save session (force quit skips save)

**Implementation:**
- Uses folke's `persistence.nvim` plugin
- Sessions stored at `~/.local/state/nvim/sessions/` (hashed by directory)
- Only saves buffers (not window layout/splits) via `options = { "buffers", "curdir", "tabpages" }`
- VimEnter autocmd detects startup mode and conditionally restores
- QuitPre autocmd detects `:qa!` (bang) and calls `persistence.stop()` to skip save

**New directory without session:** Shows neo-tree + fzf picker (original behavior)
**Existing session:** Shows neo-tree + restores buffers (skips fzf picker)

#### GitHub Browse Keybindings

Added snacks.gitbrowse keybindings for opening commits and files in GitHub.

**File:** `nvim/plugins/ui.lua`
| Key | Action |
|-----|--------|
| `,go` | Open current line's blame commit in GitHub |
| `,gf` | Open current file in GitHub |

**`,go` implementation:** Uses `git blame -L <line>,<line> --porcelain` to get the commit that last modified the current line, then opens it via gitbrowse. Handles uncommitted lines (shows warning).

Useful workflow: `,gb` (blame) → `,go` (open commit) → find PR on GitHub.

#### gx.nvim URL Opener

Added gx.nvim plugin for opening URLs from within Neovim.

**File:** `nvim/plugins/editor.lua`
| Key | Action |
|-----|--------|
| `gx` | Open URL under cursor in browser |

Features:
- Works in normal and visual modes
- Detects URLs with/without protocol
- Handles GitHub issues (`#123`), npm packages, Go imports
- Falls back to web search if no URL detected
- Useful for opening URLs in terminal buffers where WezTerm can't detect them (exit terminal mode with `<Esc>`, then `gx`)

#### Terminal Drawer Line Numbers

Disabled line numbers in terminal drawers (`,z` and `,x`) for cleaner appearance.

**File:** `nvim/util/bottom_drawers.lua`
- Sets `number=false` and `relativenumber=false` for terminal windows

#### claudecode.nvim Diff Panel Improvements

Improved diff panel behavior for a less disruptive experience.

**File:** `nvim/plugins/tools.lua`
- `layout = "vertical"` - side-by-side diff view
- `auto_close_on_accept = true` - panel closes after accepting changes
- `keep_terminal_focus = true` - focus stays in Claude terminal after diff opens

#### Terminal Mouse Click Handling

Fixed terminal panes entering visual mode on click instead of terminal mode.

**File:** `nvim/config/keymaps.lua`
- Added `TermOpen` autocommand with `<LeftMouse>` and `<LeftRelease>` handlers
- Tracks click position to distinguish single clicks from drags
- Single click → enters terminal mode (`startinsert`)
- Click-and-drag → preserves visual selection for text copying
- Uses `vim.b.terminal_click_pos` buffer variable to track state

### 2025-12-11

#### Lualine Branch Name Truncation

Truncate long git branch names in the middle to preserve both prefix and suffix visibility.

**File:** `nvim/plugins/ui.lua`
- Shows first 9 and last 9 chars with ellipsis: `ankit/fea…nch-name`
- Prevents long branch names from pushing LSP info off the statusline
- Uses lualine's built-in `fmt` option on the branch component

#### fzf-lua Visual Selection Pre-fill

When pressing `<C-p>` in visual mode, the selected text is used as the initial query.

**File:** `nvim/plugins/editor.lua`
- Detects visual mode (`v` or `V`) and extracts selection
- Passes selection as `query` option to fzf-lua
- Useful for quickly finding files by selecting a filename/path in code

#### typescript-tools Memory Increase for Large Monorepos

Increased `tsserver_max_memory` from 16GB to 28GB for large codebases.

**File:** `nvim/plugins/lang.lua`
- Fixes "gd not working" issue in large monorepos like Notion (500k+ lines)
- 28GB matches what Notion's custom tsserver wrapper allocates for 64GB+ machines
- tsserver was appearing attached but not responding due to memory constraints

#### Snacks.nvim Lazygit & Scratch Buffers

Added new snacks.nvim integrations.

**File:** `nvim/plugins/ui.lua`
| Key | Action |
|-----|--------|
| `,gg` | Open Lazygit |
| `,S` | Open scratch buffer |
| `,Sb` | Select scratch buffer |

Also enabled: `dim`, `image` features in snacks.nvim.

#### Pane-Specific Neovim RPC Sockets

Fixed multiple Neovim instances conflicting over the same socket.

**File:** `nvim/config/options.lua`
- Socket path now includes WezTerm pane ID: `~/.cache/nvim/server-{pane_id}.sock`
- WezTerm click handler uses `pane:pane_id()` to find correct socket
- Falls back to `server.sock` for non-WezTerm terminals

#### Bufferline Close with snacks.bufdelete

Buffer close commands now use snacks.bufdelete to preserve window layout.

**File:** `nvim/plugins/ui.lua`
- `close_command` and `right_mouse_command` use `snacks.bufdelete()`
- Prevents window from closing when closing a buffer

### 2025-12-08

#### Reverted to nvim-scrollbar (Removed neominimap)

Reverted from neominimap.nvim back to nvim-scrollbar due to issues with text being hidden behind the floating minimap and stray characters appearing in split layout.

**File:** `nvim/plugins/ui.lua`
- Simple scrollbar on the right edge (no text overlap issues)
- Shows: cursor position, diagnostics, git changes, search matches
- Colors matched to Tokyo Night theme
- Handlers: cursor, diagnostic, gitsigns, search

#### eslint_d Formatter Fix

Fixed eslint_d formatting not running on save due to module loading loop error.

**File:** `nvim/plugins/lsp.lua`
- Moved `require("none-ls.diagnostics.eslint_d")` and `require("none-ls.formatting.eslint_d")` into the `sources` table
- Previously used `null_ls.register()` after setup, which caused circular dependency
- Now eslint --fix runs correctly on save for JS/TS files

#### Removed ssh oh-my-zsh Plugin

**File:** `.zshrc`
- Removed `ssh` from oh-my-zsh plugins list (was causing issues)
- Plugins now: `git gitfast npm`

### 2025-12-07

#### neominimap.nvim (Removed - see 2025-12-08)

Was briefly added as a floating minimap, then tried split layout, but had persistent issues:
- Float layout: text hidden behind minimap
- Split layout: stray "p" character appearing, conflicts with bufferline

**Removed in favor of nvim-scrollbar**

#### Improved Page Scrolling (`_` and `+`)

Changed page scroll to scroll `window_height - 10` lines instead of full page.

**File:** `nvim/config/keymaps.lua`
- Creates ~10 line overlap between scrolls for easier document scanning
- Uses `<C-y>` / `<C-e>` with calculated count
- Works in normal and visual modes

#### LSP Restart Keybinding

Added `,rl` to restart all LSP servers (skips null-ls to avoid warning).

**File:** `nvim/config/keymaps.lua`
```lua
vim.keymap.set("n", "<leader>rl", function()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name ~= "null-ls" then
            vim.cmd("LspRestart " .. client.name)
        end
    end
end, { desc = "Restart LSP servers" })
```

#### Global Floating Window Border

Added `vim.o.winborder = "rounded"` for consistent borders on all floating windows.

**File:** `nvim/config/options.lua`

#### typescript-tools Lazy-Load Fix

Fixed race condition where typescript-tools wouldn't attach on first file open.

**File:** `nvim/plugins/lang.lua`
- Added `vim.schedule(function() vim.cmd("LspStart typescript-tools") end)` after setup
- Forces LSP to attach to the buffer that triggered the lazy-load

#### Dynamic Bottom Drawer Layout

Refactored bottom drawer system to use dynamic ordering based on open sequence.

**File:** `nvim/util/bottom_drawers.lua`
- Drawers appear left-to-right in the order they were opened
- All open drawers share equal width (1=100%, 2=50% each, 3=33% each)
- State cached in `_G._bottom_drawers` to persist across `dofile()` calls
- New state structure: `open_order = {}` tracks which drawers are open

#### LSP Float Borders & Duplicate Diagnostics Fix

Added rounded borders to all LSP floating windows for better visibility.

**File:** `nvim/plugins/lsp.lua`
- Diagnostic floats now have `border = "rounded"`
- Hover (`K`) windows have rounded borders
- Signature help windows have rounded borders

**Duplicate diagnostics fix:**
- Disabled `ts_ls` in mason-lspconfig handlers (typescript-tools.nvim handles TypeScript)
- Disabled `eslint` LSP (eslint_d via none-ls is faster)
- Removed `eslint` from `ensure_installed` list

```lua
handlers = {
    default_setup,
    ts_ls = function() end,    -- typescript-tools handles TS
    eslint = function() end,   -- eslint_d via none-ls
},
```

#### Option-Shift Pane Navigation

Added `Option-Shift+Arrow` (`<M-S-Arrow>`) as alternative to `Shift+Arrow` for pane navigation.

**File:** `nvim/config/keymaps.lua`
- Consolidated pane navigation into single loop (was 21 lines, now 12)
- Works in all modes: normal, insert, visual, terminal
- Terminal mode exits to normal mode before switching

#### Zoom Fix for Terminal Mode

Fixed "Can't re-enter normal mode from terminal mode" error when zooming from terminal.

**File:** `nvim/plugins/editor.lua`
- Detects if in terminal mode (`vim.fn.mode() == "t"`)
- Sends `<C-\><C-n>` to exit terminal mode first
- Uses `vim.schedule()` to defer zoom after mode change

#### trouble.nvim Winbar Timing Fix

Fixed trouble.nvim diagnostics panel not showing red title on first open.

**File:** `nvim/util/bottom_drawers.lua`
- Added retry mechanism with `vim.defer_fn` (10ms intervals, up to 10 attempts)
- Searches for window with `filetype == "trouble"` to apply winbar
- Changed title from "Diagnostics" to "Trouble.nvim Diagnostics"

#### Zsh Startup Time Fix (14s → 0.2s)

Fixed critical bug where `setup.sh` was appending duplicate source lines to `~/.zshrc` on every run.

**Root cause:** `grep -Fxq "Source Ankit's zshrc"` required exact whole-line match, but the file contained `# Source Ankit's zshrc` (with `#` prefix). This caused setup.sh to think the line wasn't present and append it again.

**Result:** `.zshrc` had 23 copies of `source ~/.dotfiles/.zshrc`, loading oh-my-zsh 23 times.

**Fixes applied:**
1. Cleaned up `~/.zshrc` to single source line
2. Fixed `setup.sh` to use `grep -Fq` (substring match) instead of `grep -Fxq` (whole line match)
3. Added lazy-loading for pyenv, rbenv, notion CLI to further speed up startup
4. Added comprehensive idempotency documentation to `setup.sh` header

**Files changed:**
- `setup.sh` - Fixed grep pattern, added idempotency header
- `~/.zshrc` - Cleaned up (not in repo, but user's file)

#### Neo-tree Migration (Replaced nvim-tree)

Migrated from **nvim-tree** to **neo-tree** for unified sidebar with git_status support.

**New keybindings:**
| Key | Action |
|-----|--------|
| `,m` | Toggle filesystem tree (no focus change) |
| `,n` | Focus tree & reveal current file |
| `,b` | Show tree (no focus change) |
| `,g` | Toggle git_status view |

**Features:**
- Multiple sources: filesystem, git_status, buffers
- Sources share same sidebar position (`,g` replaces filesystem view)
- Auto-opens on `nvim .` with fzf picker
- Integrates with snacks.nvim rename

**Files changed:**
- `nvim/plugins/editor.lua` - Neo-tree config (~160 lines)
- `nvim/plugins/ui.lua` - Bufferline offset updated to `neo-tree`

#### Bottom Drawers System (NEW)

Created unified drawer system for terminals and diagnostics at bottom of screen.

**New file:** `nvim/util/bottom_drawers.lua`

**Drawer keybindings:**
| Key | Action | Color |
|-----|--------|-------|
| `,z` | Toggle Terminal Z (left) | Blue (#2563eb) |
| `,x` | Toggle Terminal X (middle) | Purple (#9333ea) |
| `,t` | Toggle Diagnostics (right) | Red (#dc2626) |
| `,q` | Close all drawer windows | - |
| `,Q` | Kill all terminals | - |

**Layout behavior:**
```
Single drawer:     [========= full width =========]
Two drawers:       [==== left ====][==== right ====]
Three drawers:     [== left ==][== mid ==][== right ==]
```

**Features:**
- Color-coded winbars with toggle hints (e.g., "Terminal Z (type ,z to toggle)")
- Side-by-side layout, auto-expands when others close
- Trouble.nvim integration for diagnostics
- Terminals persist across toggles (only windows hide)

#### trouble.nvim Integration

Added trouble.nvim for LSP diagnostics drawer.

**Config:** `nvim/plugins/editor.lua`
- Mode: diagnostics only
- Window management handled by bottom_drawers.lua
- Custom winbar disabled (uses drawer system's styled winbar)

#### Claude Code Terminal Styling

Updated claudecode.nvim terminal with orange theme winbar.

**File:** `nvim/plugins/tools.lua`
- Orange background (#ea580c)
- Dynamic title from `b:term_title`
- Hint: "(type ,a to toggle)"

#### WezTerm Option Key Fixes

Fixed Option-Shift keybindings for buffer navigation and zoom.

**File:** `wezterm/wezterm.lua`
- `Option-Shift-[` / `Option-Shift-]` → Buffer navigation (sends F13/F14)
- `Option-Shift-Enter` → Zoom toggle

### 2025-12-07

#### Vim/Neovim Complete Separation

Vim and Neovim configurations are now fully distinct:

**Neovim (Lua-first):**
- All keymaps in `nvim/config/keymaps.lua` (~200 lines)
- All plugins via lazy.nvim in `nvim/plugins/*.lua`
- Config reload via `,r` re-sources Lua files + `vimconfig/main.vim`

**Vim (VimScript):**
- All keymaps in `vimconfig/mappings.vim` (now Vim-only, skips for nvim)
- All plugins via vim-plug in `vimconfig/plugins.vim`
- Config reload via `,r` sources `$MYVIMRC`

**Changes:**
- `vimconfig/mappings.vim` - Added `if has('nvim') finish endif` guard at top
- `vimconfig/terminal.vim` - Deleted, consolidated into `mappings.vim`
- `nvim/config/keymaps.lua` - Full rewrite with all keymaps from VimScript
- `,rs` → `,r` (shorter reload keybinding)

#### LazyVim-style Directory Restructure

Reorganized `nvim/` directory following LazyVim conventions for better maintainability.

**New Structure:**
```
nvim/
├── plugins/          # Plugin specs split by category
│   ├── init.lua      # Combines all specs
│   ├── ui.lua        # Theme, statusline, visual
│   ├── editor.lua    # Navigation, editing, search
│   ├── lsp.lua       # LSP, completion, linting
│   ├── lang.lua      # Treesitter, language-specific
│   └── tools.lua     # Claude, image viewer
├── config/           # Global settings
│   ├── options.lua   # vim.g, vim.o
│   └── keymaps.lua   # Global keymaps
└── util/             # Utility modules
    ├── file_cache.lua
    ├── context_menu.lua
    └── bottom_drawers.lua
```

**Changes:**
- Split monolithic `plugins.lua` (~850 lines) into 5 category files
- Moved global settings from `main.lua` to `config/options.lua` and `config/keymaps.lua`
- Moved utilities to `util/` subdirectory
- Removed unused `keymap.lua`
- Updated `nvim/init.lua` to use `dofile()` for loading (better for nested dofile calls)

#### lazy.nvim Migration (Major Refactor)

Migrated Neovim from **vim-plug** to **lazy.nvim** for proper lazy-loading and instant startup.

**Architecture Change:**
```
Before: nvim/init.lua → lazy.setup(plugins) → require('nvim.main')
        (main.lua did require() at top, loading ALL plugins immediately)

After:  nvim/init.lua → lazy.setup(dofile(plugins/init.lua)) → vimconfig/main.vim → dofile(config/*.lua)
        (plugins split by category, config split into options + keymaps)
```

**Key Files Changed:**
- `nvim/init.lua` - Bootstraps lazy.nvim, uses dofile for plugin specs and config
- `nvim/plugins/*.lua` - Plugin specs split by category (ui, editor, lsp, lang, tools)
- `nvim/config/options.lua` - Global vim.g/vim.o settings
- `nvim/config/keymaps.lua` - Global keybindings
- `vimconfig/plugins.vim` - Removed Neovim-specific plugins (now Vim-only)

**Lazy-Loading Triggers Used:**
| Trigger | Plugins |
|---------|---------|
| `lazy = false` | tokyonight (colorscheme, no flicker) |
| `event = "VeryLazy"` | snacks, lualine, scrollbar, tpope plugins |
| `event = "BufReadPre"` | lspconfig, none-ls, gitsigns, vim-sleuth |
| `event = "BufReadPost"` | treesitter |
| `event = "BufAdd"` | bufferline |
| `event = "InsertEnter"` | nvim-cmp, nvim-autopairs |
| `event = "LspAttach"` | lsp-lens |
| `cmd = {...}` | neo-tree, fzf-lua, claudecode, trouble |
| `keys = {...}` | most plugins with leader keybindings |
| `ft = {...}` | typescript-tools, emmet, language-specific |

**Startup Time Achievement:**
- Before: ~200-400ms
- After: **37ms** (target was <50ms)

**Other Changes:**
- `<esc>` now closes lazy.nvim UI
- Replaced `jiangmiao/auto-pairs` with `windwp/nvim-autopairs` (Lua-native)
- Removed `debug = true` from none-ls (was spamming logs)
- neo-tree auto-opens when launching `nvim .` (directory argument)
- Dashboard disabled for faster startup (snacks.dashboard.enabled = false)

#### VimScript → Lua Plugin Migrations

Replaced legacy VimScript plugins with modern Lua alternatives:

| Old (VimScript) | New (Lua) | Notes |
|-----------------|-----------|-------|
| `preservim/nerdcommenter` | `numToStr/Comment.nvim` | Treesitter-aware, `<leader>c` toggles |
| `tpope/vim-surround` | `kylechui/nvim-surround` | Same keybindings (`cs`, `ds`, `ys`), built-in dot-repeat |
| `justinmk/vim-sneak` | `folke/flash.nvim` | Labeled jumps, treesitter search, `s`/`S` |
| `bronson/vim-trailing-whitespace` | `echasnovski/mini.trailspace` | Highlights trailing whitespace |
| `tpope/vim-repeat` | (removed) | nvim-surround has built-in dot-repeat |

**Keybinding Changes:**
- `<leader>c` - Toggle comment (was `<leader>c<space>` with nerdcommenter)
- `s`/`S` - Flash jump with labels (was vim-sneak 2-char search)
- `cs`, `ds`, `ys` - Unchanged (nvim-surround is drop-in compatible)

### 2025-12-06

#### Less Pager Configuration (NEW)

- **`.lesskey` (NEW):** Consolidated LESS configuration into a single file using lesskey format
  - `#env` section: `LESS = -x2RMS --mouse` (tab stops, raw chars, verbose prompt, chop lines, mouse)
  - `#command` section: Custom keybindings for vim-like navigation
- **Keybindings:** `_`/`+` for full page up/down, `{`/`}` for half-page scroll
- **Cleanup:** Removed duplicate `LESS` exports from `.profile` and `.zshrc`

#### Neo-tree Pane Navigation Fix

- **Problem:** Shift+Arrow keys for pane navigation didn't work in tree buffer
- **Cause:** Tree buffer-local keymaps override global mappings
- **Fix:** Added window mappings in neo-tree setup for Shift+Arrow keybindings
- **File:** `nvim/plugins/editor.lua` (neo-tree window.mappings)

#### Brewfile Additions

- **CLI tools added:**
  - `withgraphite/tap/graphite` - Graphite CLI for stacked PRs
  - `claude-code` - Claude Code AI assistant (cask)
  - `1password-cli` - 1Password CLI (cask)

#### setup.sh Improvements

- **Homebrew updates:** Now runs `brew update` before `brew bundle`, shows update progress
- **Verbose output:** Shows each package being installed (gray, indented) for both Homebrew and npm
- **New symlink:** `.lesskey` → `~/.lesskey`
- **Fixed:** Piping to `while read` was breaking `brew bundle` - now captures output first

#### Major Lua Migration

- **`nvim/` directory:** All Neovim-specific Lua config moved to dedicated directory (previously scattered in `vimconfig/`)
- **`nvim/main.lua` (~660 lines):** Consolidated ALL Neovim-specific configuration. Contains setup for: nvim-tree, lualine, gitsigns, bufferline, fzf-lua, treesitter, LSP, mason, cmp, snacks.nvim, typescript-tools, none-ls, image.nvim, claudecode.nvim, lsp-lens.nvim.
- **`nvim/context_menu.lua`:** Right-click context menu using fzf-lua's `vim.ui.select()` integration.
- **`nvim/file_cache.lua`:** Persisted file cache system for instant file picker. Caches `git ls-files` results to disk, watches `.git/index` for automatic invalidation using `vim.uv.new_fs_event()`. Provides sub-50ms file picker in large repos.
- **`nvim/keymap.lua`:** Helper functions for defining keymaps.
- **`nvim/init.lua`:** New Lua entry point replaces `init-nvim.vim`. Sources shared VimScript config then requires `nvim/main`.

#### fzf-lua Migration (Replaced Telescope)

- **Why:** Much faster for large repos (100k+ files). Native fzf binary + bat previewer.
- **Features:**
  - `git ls-files` for instant file listing in git repos, `fd` fallback for non-git
  - `rg` for live grep with smart-case and hidden files
  - bat previewer with Tokyo Night theme
  - `vim.ui.select()` integration (replaces telescope-ui-select)
- **Keybindings:** `<C-p>` (cached files), `<C-o>` (live grep), `<leader>ll/lk/lj/lr`

#### snacks.nvim Integration (QoL Plugin Collection)

Folke's snacks.nvim replaces several individual plugins:

- `bufdelete` - Better buffer deletion (preserves window layout)
- `bigfile` - Large file optimizations (disables slow features)
- `quickfile` - Quick file picker from recent files
- `notifier` - Toast notifications
- `rename` - LSP rename with preview, integrates with nvim-tree file renames
- `words` - Highlight word under cursor across buffer
- `gitbrowse` - Open current file in GitHub
- `input` - Better input UI
- `scope` - Scope-based animations/dimming
- `scroll` - Smooth scrolling with configurable animation
- `indent` - Animated indent guides
- `dashboard` - Startup screen with recent files and projects
- `terminal` - Replaces custom `terminal.vim` functions, used by claudecode.nvim

#### none-ls Integration (Linters & Formatters via LSP)

- **Linters:** hadolint, shellcheck, markdownlint, yamllint, actionlint, tflint
- **Formatters:** prettier (web files), biome (JS/TS if biome.json exists), stylua, shfmt, terraform_fmt
- **eslint_d:** Via none-ls-extras for fast eslint
- **Format on save:** Auto-formats on `:w` for supported filetypes
- **Mason integration:** `mason-null-ls` auto-installs all tools

#### typescript-tools.nvim

- Direct tsserver communication (bypasses typescript-language-server npm package)
- Separate diagnostic server for better performance
- 16GB memory limit for large projects
- Auto-close JSX tags
- Inlay hints for parameters, return types, variable types

#### New Plugins

- **image.nvim:** View images (PNG, JPG, GIF, WebP) in terminal using kitty graphics protocol. Requires ImageMagick.
- **claudecode.nvim:** Claude Code editor integration. `<leader>a` toggles Claude terminal (via snacks), `<leader>sa` adds current file to context.
- **lsp-lens.nvim:** Shows reference/implementation counts above functions. Git author info. Toggle with `gL`.

#### Brewfile & setup.sh Improvements

- **Brewfile:** Declarative Homebrew deps - git, neovim, tmux, node, bat, fd, fzf, git-delta, ripgrep, imagemagick, shellcheck, tflint, wezterm.
- **setup.sh now:**
  - Runs `brew bundle` if Brewfile exists
  - Installs bat Tokyo Night theme to `$(bat --config-dir)/themes/`
  - Compiles WezTerm terminfo to `~/.terminfo`
  - Symlinks `.markdownlintrc`

#### WezTerm Enhancements

- Theme: Tokyo Night (was Dracula)
- New keybindings:
  - `CMD+SHIFT+S` - Pane swap mode (select which pane to swap with)
  - `CMD+ALT+Arrows` - Tab navigation
  - `CMD+F` - Search scrollback
  - `CMD+SHIFT+X` - Copy mode (vim-like navigation)
  - `CMD+K` - Clear scrollback
- Quick select patterns for git hashes, UUIDs

#### Markdown Support

- `ftplugin/markdown.vim` - Soft wrapping for comfortable reading
- `j`/`k` navigate by display lines (not file lines)
- No colorcolumn (looks weird with wrap)
- `.markdownlintrc` - Disables line-length rule (MD013)

### 2025-12-05

- **WezTerm cursor shape workaround:** The `wezterm` terminfo is missing `Ss`/`Se` capabilities, so Neovim's `guicursor` setting doesn't send cursor shape escape sequences. Added Lua workaround in `vimconfig/options.vim` that writes DECSCUSR sequences directly via `io.write()`. Cursor shapes: block (normal/visual/command), bar (insert), underline (replace/operator-pending).

### 2025-12-04

- **Git delta integration:** Added `.gitconfig` with delta as pager for syntax-highlighted diffs. Uses `gruvmax-fang` Gruvbox theme from `themes.gitconfig`. Features: line numbers, navigation, hyperlinks, `zdiff3` merge conflict style, auto-prune on fetch.
- **Neovim terminal:** Added `vimconfig/terminal.vim` with built-in `:terminal` support. Horizontal split at 30% height, toggle with `<Leader>z/x`, exit terminal mode with `;;q` or `<ESC><ESC>`.
- **Telescope context menu:** Added `vimconfig/helpers/context_menu.vim` with right-click context menu. Dynamic sections for LSP (definition, references, rename), Diagnostics, Git (blame, stage, diff), File ops, Edit ops. Uses `vim.ui.select()` → Telescope ui-select.
- **Mason/LSP expansion:** Expanded to 14 auto-installed language servers via mason-lspconfig: ts_ls, eslint, cssls, htmlls, jsonls, pylsp, dockerls, docker_language_server, docker_compose_language_service, lua_ls, vimls, yamlls.
- **Treesitter parsers:** Comprehensive parser list: typescript, tsx, html, css, json, markdown, markdown_inline, jsdoc, vimdoc, yaml, vim, lua, bash, dockerfile, go, git_config, git_rebase, gitignore, gitcommit, comment, tsv.
- **WezTerm enhancements:** Expanded configuration with Dracula theme, FantasqueSansM Nerd Font, WebGPU acceleration, CMD-based macOS keybindings for pane/tab management.

### 2025-11-26

- **Setup.sh optimizations:** Added idempotency checks for npm package installation and git completion file downloads. Repeat runs now skip these operations if already completed, reducing setup time from ~60 seconds to ~5 seconds. Fixed recursive symlink bug by using `ln -sfn` instead of `ln -sf`. Extracted npm packages to variable for maintainability. Added verbose skip messages for transparency.
- **WezTerm support added:** Added `wezterm/` directory with full directory symlink to `~/.config/wezterm`. This mirrors the pattern used for vim's ftplugin and vimconfig directories, allowing future expansion with themes, plugins, and helper Lua files without modifying setup scripts. Fixed missing cleanup for terminal configs in clean.sh.

### 2025-11-25

- **Documentation system established:** Created this CLAUDE.md with automatic maintenance instructions. Claude instances should now proactively update documentation as they discover patterns and make changes.
- **Initial context populated:** Extracted key information from README.md to establish baseline understanding of repository structure and purpose.

---

## Notes & Patterns

**This section for ad-hoc observations that don't fit above categories:**

- **CRITICAL - Idempotency:** `setup.sh` MUST be idempotent. Running it 1000 times must produce the same result as running it once. When modifying setup.sh:
  - ALWAYS check if work is needed before making changes
  - Use `grep -Fq` (substring), NOT `grep -Fxq` (whole line) for content checks
  - Never append to files without checking if content already exists
  - See setup.sh header for full implementation rules
- **CRITICAL - Special characters:** This repository uses Unicode box-drawing and other special characters (e.g., `│` U+2502, not `|`). LLMs frequently replace these with ASCII equivalents, breaking visual appearance. **Always preserve exact characters when editing.** If you see characters like `│`, `─`, `┌`, `└`, `├`, `┤`, `┬`, `┴`, `┼` - do NOT replace them with `|`, `-`, `+`, etc.
- **Git branch structure:** Main branch is `main`. PRs should target `main`.
- **Leader keys:** Vim/Neovim use `,` (leader) and `;` (local leader) for custom mappings
- **Naming convention:** Config files use lowercase with dashes (`.tmux.conf`, `.bash_profile`)
- **Symlink pattern:** Setup script creates symlinks FROM `.dotfiles/` TO standard locations (not the reverse)
- **Vim/Neovim separation:** These are distinct configs, NOT sharing code. Neovim is Lua-first with lazy.nvim. Vim is VimScript with vim-plug. Don't try to make them compatible.
