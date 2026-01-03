# Dotfiles Changelog

All notable changes and discoveries in this dotfiles repository.

## 2026-01-02

### Features
- **Claude Code settings in dotfiles** - Stop hook configuration now managed in `claude-settings.json`. `setup.sh` merges hooks into `~/.claude/settings.json` for cross-repo usage (`setup.sh`, `claude-settings.json`)
- **Claude Code auto-open** - Automatically opens Claude Code terminal when launching Neovim to a directory (`nvim .` or `nvim`). Claude Code terminal gets focus. Disabled when opening specific files (`nvim/plugins/tools.lua`)
- **Claude Code status indicator** - Terminal title shows AI agent status with per-instance emojis: ⚠️ (stale), ⏳ (diff pending), 🔄 (connecting), 🤖 (thinking), ✏️ (idle/your turn). Detects all Claude instances in current directory via CPU monitoring (`nvim/util/claude_status.lua`)
- **LSP status indicator** - Terminal title shows LSP state on right side: 🔵 (busy/processing), 🟢 (ready). Instance-wide detection persists across all panes including terminals (`nvim/util/claude_status.lua`)
- **Claude Code stop hook** - Blocks Claude from stopping if work appears incomplete. Checks for incomplete todos and staged uncommitted git changes (`scripts/claude-stop-hook.sh`)
- **Mode-aware zoom borders** - Zoom window border color changes based on Vim mode: blue (normal), green (insert), magenta (visual), yellow (command), red (replace) (`nvim/util/zoom_border.lua`)

### Improvements
- **Terminal scrollback optimization** - Reduced scrollback from 10000 to 1000 lines for Claude Code output. Prevents severe slowdowns at 12k+ lines (`nvim/config/options.lua`)
- **Terminal buffer performance** - Disabled expensive visual features in terminal buffers: signcolumn, foldcolumn, cursorline, cursorcolumn, spell, list (`nvim/config/options.lua`)

### Bug Fixes
- **fzf-lua startup focus** - Removed auto-open behavior that was stealing focus on Neovim startup (`nvim/plugins/editor.lua`)

---

## 2025-12-27

### Features
- **`/remember-about-me` Claude Code skill** - Custom skill for persisting user preferences to `~/.claude/CLAUDE.md`. Automatically categorizes and adds information as concise bullet points (`.claude/commands/remember-about-me.md`)

### Improvements
- **Nested vim optimizations** - When running vim inside neovim terminal panes: aliases `v`/`vi` to vim (not nvim), disables mouse, uses simpler cursor, faster updatetime (`.zshrc`, `vimconfig/options.vim`)
- **vim-airline branch truncation** - Shows first 9 and last 9 chars with ellipsis for branches over 20 chars, matching lualine (`vimconfig/options.vim`)
- **setup.sh resilience** - Removed `set -e`, gracefully skips npm packages if Node.js unavailable, all sections warn and continue instead of crashing (`setup.sh`)
- **Repository public-ready** - Removed personal info, replaced hardcoded paths with `$HOME` in `.zshrc`

### Bug Fixes
- **Session restore empty buffers** - Only deletes `[No Name]` buffers when session is actually restored (`nvim/plugins/editor.lua`)
- **Neo-tree in bufferline** - Added `custom_filter` to exclude neo-tree filetype from buffer tabs (`nvim/plugins/ui.lua`)

---

## 2025-12-19

### Features
- **Session persistence (persistence.nvim)** - Auto-saves/restores sessions for directory-based workflows. `nvim .` restores previous session, `nvim file.txt` opens only that file, `:qa!` skips save. Sessions stored at `~/.local/state/nvim/sessions/` (`nvim/plugins/editor.lua`)
- **GitHub browse keybindings** - `,go` opens current line's blame commit in GitHub (uses `git blame` + gitbrowse), `,gf` opens current file (`nvim/plugins/ui.lua`)
- **gx.nvim URL opener** - `gx` opens URLs under cursor in browser. Detects GitHub issues, npm packages, Go imports. Useful for terminal buffers where WezTerm can't detect URLs (`nvim/plugins/editor.lua`)

### Improvements
- **Terminal drawer line numbers** - Disabled line numbers in terminal drawers (`,z` and `,x`) for cleaner appearance (`nvim/util/bottom_drawers.lua`)
- **claudecode.nvim diff panel** - Vertical layout (side-by-side), auto-closes on accept, keeps terminal focus (`nvim/plugins/tools.lua`)

### Bug Fixes
- **Terminal mouse click handling** - Fixed terminal panes entering visual mode on click instead of terminal mode. Single click → terminal mode, click-and-drag → visual selection (`nvim/config/keymaps.lua`)

---

## 2025-12-11

### Features
- **Snacks.nvim Lazygit & scratch buffers** - `,gg` opens Lazygit, `,S` opens scratch buffer, `,Sb` selects scratch buffer. Enabled `dim` and `image` features (`nvim/plugins/ui.lua`)

### Improvements
- **Lualine branch truncation** - Shows first 9 and last 9 chars with ellipsis (`ankit/fea…nch-name`) to prevent long branches from pushing LSP info off statusline (`nvim/plugins/ui.lua`)
- **fzf-lua visual selection pre-fill** - `<C-p>` in visual mode uses selected text as initial query (`nvim/plugins/editor.lua`)
- **typescript-tools memory increase** - Increased `tsserver_max_memory` from 16GB to 28GB for large monorepos (fixes "gd not working" in 500k+ line codebases) (`nvim/plugins/lang.lua`)
- **Pane-specific Neovim RPC sockets** - Socket path includes WezTerm pane ID to prevent conflicts: `~/.cache/nvim/server-{pane_id}.sock` (`nvim/config/options.lua`)
- **Bufferline close with snacks.bufdelete** - Preserves window layout when closing buffers (`nvim/plugins/ui.lua`)

---

## 2025-12-08

### Improvements
- **Reverted to nvim-scrollbar** - Removed neominimap due to text overlap and rendering issues. Simple scrollbar shows cursor position, diagnostics, git changes, search matches (`nvim/plugins/ui.lua`)

### Bug Fixes
- **eslint_d formatter fix** - Moved `require()` calls into `sources` table to fix module loading loop. Now eslint --fix runs correctly on save (`nvim/plugins/lsp.lua`)

### Configuration
- **Removed ssh oh-my-zsh plugin** - Was causing issues. Plugins now: `git gitfast npm` (`.zshrc`)

---

## 2025-12-07

### Features
- **Bottom drawers system** - Unified drawer system for terminals and diagnostics at bottom of screen. `,z` (Terminal Z, blue), `,x` (Terminal X, purple), `,t` (Diagnostics, red), `,q` closes all, `,Q` kills all terminals. Color-coded winbars, dynamic layout, terminals persist across toggles (`nvim/util/bottom_drawers.lua`)
- **trouble.nvim integration** - LSP diagnostics drawer, integrates with bottom drawer system (`nvim/plugins/editor.lua`)
- **Claude Code terminal styling** - Orange theme winbar, dynamic title from `b:term_title` (`nvim/plugins/tools.lua`)

### Improvements
- **Improved page scrolling** - `_` and `+` scroll window height - 10 lines for ~10 line overlap between pages (`nvim/config/keymaps.lua`)
- **Global floating window border** - `vim.o.winborder = "rounded"` for consistent borders (`nvim/config/options.lua`)
- **Dynamic bottom drawer layout** - Drawers appear left-to-right in open order, equal width distribution (`nvim/util/bottom_drawers.lua`)
- **LSP float borders** - Rounded borders for diagnostics, hover, signature help (`nvim/plugins/lsp.lua`)
- **Option-Shift pane navigation** - Added `Option-Shift+Arrow` as alternative to `Shift+Arrow`, consolidated into single loop (21→12 lines) (`nvim/config/keymaps.lua`)

### Bug Fixes
- **typescript-tools lazy-load fix** - Forces LSP attach with `vim.schedule()` to fix race condition (`nvim/plugins/lang.lua`)
- **LSP duplicate diagnostics** - Disabled `ts_ls` and `eslint` LSP (typescript-tools and eslint_d handle these) (`nvim/plugins/lsp.lua`)
- **Zoom from terminal mode** - Detects terminal mode, sends `<C-\><C-n>` to exit before zoom (`nvim/plugins/editor.lua`)
- **trouble.nvim winbar timing** - Added retry mechanism with `vim.defer_fn` (10ms intervals, up to 10 attempts) (`nvim/util/bottom_drawers.lua`)
- **Zsh startup time (14s → 0.2s)** - Fixed critical bug where `setup.sh` was appending duplicate source lines. Changed from `grep -Fxq` (whole line) to `grep -Fq` (substring) match. Added lazy-loading for pyenv, rbenv, notion CLI (`setup.sh`, `.zshrc`)

### Major Refactors
- **Vim/Neovim complete separation** - Vim and Neovim now fully distinct. Neovim: all keymaps in Lua (`nvim/config/keymaps.lua`), Vim: all keymaps in VimScript (`vimconfig/mappings.vim`). Added `if has('nvim') finish endif` guard to vim mappings
- **LazyVim-style directory restructure** - Reorganized `nvim/` following LazyVim conventions: `plugins/` split by category (ui, editor, lsp, lang, tools), `config/` for settings (options, keymaps), `util/` for utility modules
- **lazy.nvim migration** - Migrated from vim-plug to lazy.nvim with proper lazy-loading. Startup time: ~200-400ms → **37ms** (target was <50ms). Split plugins into categories, moved config to `config/options.lua` and `config/keymaps.lua` (`nvim/init.lua`, `nvim/plugins/*.lua`)
- **Neo-tree migration** - Replaced nvim-tree with neo-tree for unified sidebar with git_status support. `,m` toggles tree, `,n` focuses tree, `,b` shows tree, `,g` toggles git status view (`nvim/plugins/editor.lua`)
- **VimScript → Lua plugin migrations** - Replaced nerdcommenter → Comment.nvim, vim-surround → nvim-surround, vim-sneak → flash.nvim, vim-trailing-whitespace → mini.trailspace, auto-pairs → nvim-autopairs. Keybinding change: `<leader>c` toggles comment (was `<leader>c<space>`)

### Configuration
- **WezTerm option key fixes** - `Option-Shift-[`/`]` for buffer navigation (sends F13/F14), `Option-Shift-Enter` for zoom toggle (`wezterm/wezterm.lua`)
- **LSP restart keybinding** - `,rl` restarts all LSP servers (skips null-ls) (`nvim/config/keymaps.lua`)

---

## 2025-12-06

### Features
- **Less pager configuration** - New `.lesskey` file consolidates LESS configuration. Env: `LESS = -x2RMS --mouse`, Keybindings: `_`/`+` for full page, `{`/`}` for half-page scroll (`.lesskey`)
- **Major Lua migration** - All Neovim-specific Lua config moved to dedicated `nvim/` directory. Created `nvim/main.lua` (~660 lines) consolidating all setup, `nvim/context_menu.lua` for right-click menu, `nvim/file_cache.lua` for persisted file cache with `vim.uv.new_fs_event()` watching
- **fzf-lua migration** - Replaced Telescope with fzf-lua for faster performance. `git ls-files` for instant listing, `fd` fallback, `rg` for live grep, bat previewer with Tokyo Night theme (`nvim/plugins/editor.lua`)
- **snacks.nvim integration** - Folke's QoL plugin collection replaces several individual plugins: bufdelete, bigfile, quickfile, notifier, rename, words, gitbrowse, input, scope, scroll, indent, dashboard, terminal
- **none-ls integration** - Linters (hadolint, shellcheck, markdownlint, yamllint, actionlint, tflint) and formatters (prettier, biome, stylua, shfmt, terraform_fmt) via LSP. eslint_d via none-ls-extras. Format on save enabled
- **typescript-tools.nvim** - Direct tsserver communication, separate diagnostic server, 16GB memory limit, auto-close JSX tags, inlay hints (`nvim/plugins/lang.lua`)
- **New plugins** - image.nvim (view images in terminal via kitty graphics), claudecode.nvim (Claude Code integration, `,a` toggles terminal), lsp-lens.nvim (reference counts above functions)

### Improvements
- **Brewfile additions** - Added graphite CLI, claude-code, 1password-cli
- **setup.sh improvements** - Runs `brew update` before bundle, verbose package install output, symlinks `.lesskey`, fixed piping to `while read` breaking `brew bundle` (`setup.sh`)
- **WezTerm enhancements** - Theme: Tokyo Night (was Dracula), new keybindings (`CMD+SHIFT+S` pane swap, `CMD+F` search, `CMD+SHIFT+X` copy mode, `CMD+K` clear scrollback), quick select patterns for git hashes/UUIDs

### Bug Fixes
- **Neo-tree pane navigation** - Added window mappings for Shift+Arrow keybindings to fix navigation in tree buffer (`nvim/plugins/editor.lua`)

### Configuration
- **Markdown support** - Soft wrapping, `j`/`k` navigate display lines, no colorcolumn, `.markdownlintrc` disables MD013 (`ftplugin/markdown.vim`)

---

## 2025-12-05

### Bug Fixes
- **WezTerm cursor shape workaround** - `wezterm` terminfo missing `Ss`/`Se` capabilities. Added Lua workaround writing DECSCUSR sequences via `io.write()`. Shapes: block (normal/visual/command), bar (insert), underline (replace) (`vimconfig/options.vim`)

---

## 2025-12-04

### Features
- **Git delta integration** - Syntax-highlighted diffs with `gruvmax-fang` Gruvbox theme. Line numbers, navigation, hyperlinks, `zdiff3` merge conflict style (`.gitconfig`, `themes.gitconfig`)
- **Neovim terminal** - Built-in `:terminal` support, horizontal split at 30% height, toggle with `<Leader>z/x`, exit with `;;q` or `<ESC><ESC>` (`vimconfig/terminal.vim`)
- **Telescope context menu** - Right-click menu with dynamic sections: LSP (definition, references, rename), Diagnostics, Git (blame, stage, diff), File ops, Edit ops (`vimconfig/helpers/context_menu.vim`)

### Dependencies
- **Mason/LSP expansion** - 14 auto-installed language servers: ts_ls, eslint, cssls, htmlls, jsonls, pylsp, dockerls, docker_language_server, docker_compose_language_service, lua_ls, vimls, yamlls
- **Treesitter parsers** - Comprehensive list: typescript, tsx, html, css, json, markdown, markdown_inline, jsdoc, vimdoc, yaml, vim, lua, bash, dockerfile, go, git_config, git_rebase, gitignore, gitcommit, comment, tsv
- **WezTerm enhancements** - Dracula theme, FantasqueSansM Nerd Font, WebGPU acceleration, CMD-based macOS keybindings

---

## 2025-11-26

### Improvements
- **setup.sh optimizations** - Idempotency checks for npm packages and git completion downloads. Repeat runs skip completed operations (60s → 5s). Fixed recursive symlink bug with `ln -sfn`, extracted npm packages to variable (`setup.sh`)
- **WezTerm support** - Added `wezterm/` directory with full directory symlink to `~/.config/wezterm`. Allows future expansion with themes, plugins, helper Lua files. Fixed missing cleanup in clean.sh

---

## 2025-11-25

### Documentation
- **Documentation system established** - Created CLAUDE.md (this file) with automatic maintenance instructions. Claude instances should proactively update documentation as patterns are discovered
- **Initial context populated** - Extracted key information from README.md to establish baseline understanding of repository structure and purpose
