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
- **Dual plugin ecosystems:**
  - Neovim → Modern Lua plugins (telescope, treesitter, native LSP)
  - Vim → Async alternatives (CtrlP, vim-lsp, NERDTree)
- **Entry points:**
  - Neovim: `init-nvim.vim` → sources shared configs
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

### Editor Configurations
- `init-vim.vim` - Vim entry point (~/.vimrc symlink target)
- `init-nvim.vim` - Neovim entry point (~/.config/nvim/init.vim symlink target)
- `init-gvim.vim` - GUI vim settings (~/.gvimrc symlink target)
- `vimconfig/` - Shared vim/nvim configuration modules
  - `vimconfig/plugins.vim` - Plugin declarations (vim-plug)
  - `vimconfig/plugin_options.vim` - Plugin configurations (telescope, treesitter, LSP, etc.)
  - `vimconfig/terminal.vim` - Built-in terminal configuration (toggle, keybindings)
  - `vimconfig/helpers/context_menu.vim` - Right-click context menu (LSP, Git, File ops)
  - `vimconfig/*.vim` - Feature-specific configs (keybindings, LSP, etc.)
- `ftplugin/` - Filetype-specific settings (symlinked to both ~/.vim/ and ~/.config/nvim/)

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
- **git-delta** - Syntax-highlighted diff pager (configured in .gitconfig)
- **Node.js & npm** - For LSP servers
  - `typescript-language-server`
  - `typescript`
  - `vscode-langservers-extracted` (HTML/CSS/JSON/ESLint)
  - `vim-language-server`

### Recommended
- **Zsh** with oh-my-zsh - Primary shell experience
- **Neovim** - Primary editor (Vim as fallback)
- **Tmux** - Terminal multiplexer
- **Kitty** or **WezTerm** - Terminal emulator (choose one or both)

### Optional Tools
- **Graphite CLI** - Enhanced git workflow
- **LM Studio CLI** - Local LLM integration
- **1Password CLI** - Password management

### Plugin Managers
- **vim-plug** - Vim/Neovim plugin management (auto-installs on first launch)
- **TPM (Tmux Plugin Manager)** - Tmux plugin management
- **oh-my-zsh** - Zsh plugin framework (if installed)

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
- **Update plugins:** `:PlugUpdate` in vim/neovim
- **Reload configs:** `rebash` (shell), `,rs` (vim/neovim), `Ctrl+A :source-file ~/.tmux.conf` (tmux)
- **Clean install:** Run `./clean.sh` then `./setup.sh`

---

## Recent Discoveries

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

*(This section for ad-hoc observations that don't fit above categories)*

- **Git branch structure:** Main branch is `main`. PRs should target `main`.
- **Leader keys:** Vim/Neovim use `,` (leader) and `;` (local leader) for custom mappings
- **Naming convention:** Config files use lowercase with dashes (`.tmux.conf`, `.bash_profile`)
- **Symlink pattern:** Setup script creates symlinks FROM `.dotfiles/` TO standard locations (not the reverse)
