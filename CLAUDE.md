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
- **Idempotent scripts:** `setup.sh` and `clean.sh` can be run multiple times safely

### Editor Philosophy

- **Shared config:** Vim and Neovim use the same base configuration (`vimconfig/*.vim`, `ftplugin/*.vim`)
- **Lua-first for Neovim:** All Neovim-specific config now lives in `nvim/` directory
- **Dual plugin managers:**
  - Neovim → **lazy.nvim** (Lua-based, lazy-loading, instant startup)
  - Vim → **vim-plug** (VimScript-based)
- **Dual plugin ecosystems:**
  - Neovim → Modern Lua plugins (fzf-lua, treesitter, native LSP, snacks.nvim)
  - Vim → Async alternatives (CtrlP, vim-lsp, NERDTree)
- **Entry points:**
  - Neovim: `init-nvim.lua` → bootstraps lazy.nvim → loads plugins → sources shared configs → requires `nvim/main.lua`
  - Vim: `init-vim.vim` → sources shared configs

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
- `init-nvim.lua` - Neovim entry point (~/.config/nvim/init.lua symlink target)
- `init-gvim.vim` - GUI vim settings (~/.gvimrc symlink target)
- `vimconfig/` - Shared vim/nvim configuration modules
  - `vimconfig/main.vim` - Shared entry point (sources install, plugins, options, mappings)
  - `vimconfig/plugins.vim` - Plugin declarations (vim-plug)
  - `vimconfig/options.vim` - Shared vim/nvim options + cursor shape workaround
  - `vimconfig/mappings.vim` - Keybindings shared between vim/nvim
  - `vimconfig/terminal.vim` - Vim-only terminal config (Neovim uses snacks.terminal)
  - `vimconfig/helpers/behave_zz.vim` - Helper for zz behavior
- `nvim/` - Neovim-specific Lua configuration (symlinked to ~/.config/nvim/nvim/)
  - `nvim/plugins.lua` - **Plugin specs for lazy.nvim** (~780 lines): all plugin declarations with inline configs for proper lazy-loading
  - `nvim/main.lua` - **Global settings only** (~24 lines): netrw disable, buffer nav, diagnostics keymaps, context menu
  - `nvim/context_menu.lua` - Right-click context menu (Lua, uses fzf-lua)
  - `nvim/file_cache.lua` - Persisted file cache for instant file picker
  - `nvim/keymap.lua` - Keymap helper functions
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
2. Test changes (reload shell with `rebash`, reload vim with `,rs`)
3. Commit and push changes
4. On other devices: `cd ~/.dotfiles && git pull`

### Common Operations

- **Update plugins:**
  - Neovim: `:Lazy update` (or `:Lazy` to open UI)
  - Vim: `:PlugUpdate`
- **Reload configs:** `rebash` (shell), `,rs` (vim/neovim), `Ctrl+A :source-file ~/.tmux.conf` (tmux)
- **Clean install:** Run `./clean.sh` then `./setup.sh`

---

## Recent Discoveries

### 2025-12-07

#### lazy.nvim Migration (Major Refactor)

Migrated Neovim from **vim-plug** to **lazy.nvim** for proper lazy-loading and instant startup.

**Architecture Change:**
```
Before: init-nvim.lua → lazy.setup(plugins) → require('nvim.main')
        (main.lua did require() at top, loading ALL plugins immediately)

After:  init-nvim.lua → lazy.setup(plugins) → vimconfig/main.vim → require('nvim.main')
        (plugins.lua has inline configs, main.lua is global settings only)
```

**Key Files Changed:**
- `init-nvim.lua` - Now bootstraps lazy.nvim, sets leader keys, configures lazy options
- `nvim/plugins.lua` (NEW, ~780 lines) - All plugin specs with inline `config`/`opts`/`keys` for lazy-loading
- `nvim/main.lua` (SLIMMED, ~24 lines) - Only global settings, no plugin configs
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
| `cmd = {...}` | nvim-tree, fzf-lua, claudecode |
| `keys = {...}` | most plugins with leader keybindings |
| `ft = {...}` | typescript-tools, emmet, language-specific |

**Startup Time Achievement:**
- Before: ~200-400ms
- After: **37ms** (target was <50ms)

**Other Changes:**
- `<esc>` now closes lazy.nvim UI
- Replaced `jiangmiao/auto-pairs` with `windwp/nvim-autopairs` (Lua-native)
- Removed `debug = true` from none-ls (was spamming logs)
- nvim-tree auto-opens when launching `nvim .` (directory argument)
- Dashboard disabled for faster startup (snacks.dashboard.enabled = false)

### 2025-12-06

#### Less Pager Configuration (NEW)

- **`.lesskey` (NEW):** Consolidated LESS configuration into a single file using lesskey format
  - `#env` section: `LESS = -x2RMS --mouse` (tab stops, raw chars, verbose prompt, chop lines, mouse)
  - `#command` section: Custom keybindings for vim-like navigation
- **Keybindings:** `_`/`+` for full page up/down, `{`/`}` for half-page scroll
- **Cleanup:** Removed duplicate `LESS` exports from `.profile` and `.zshrc`

#### NvimTree Pane Navigation Fix

- **Problem:** Shift+Arrow keys for pane navigation didn't work in NvimTree buffer
- **Cause:** NvimTree's buffer-local keymaps override global mappings from `mappings.vim`
- **Fix:** Added `on_attach` function to nvim-tree setup that applies buffer-local Shift+Arrow keybindings
- **File:** `nvim/main.lua` (nvim-tree on_attach function)

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
- **`init-nvim.lua`:** New Lua entry point replaces `init-nvim.vim`. Sources shared VimScript config then requires `nvim/main`.

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

- **Git branch structure:** Main branch is `main`. PRs should target `main`.
- **Leader keys:** Vim/Neovim use `,` (leader) and `;` (local leader) for custom mappings
- **Naming convention:** Config files use lowercase with dashes (`.tmux.conf`, `.bash_profile`)
- **Symlink pattern:** Setup script creates symlinks FROM `.dotfiles/` TO standard locations (not the reverse)
- Always remember that as I improve my neovim setup, i want to maintain as much backward compatibility with vim. Be mindful of the fact that most of the code runs on both nvim and vim.
