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
- Modern terminal setup (kitty + tmux) with vi-mode

---

## Architecture & Patterns

### Configuration Strategy
- **Symlink-based:** All configs symlinked from `~/.dotfiles/` to standard locations (`~/.vimrc`, `~/.config/nvim/`, etc.)
- **Version controlled:** Entire dotfiles folder is a git repo for easy sync across devices
- **Idempotent scripts:** `setup.sh` and `clean.sh` can be run multiple times safely

### Editor Philosophy
- **Shared config:** Vim and Neovim use the same base configuration (`config/*.vim`, `ftplugin/*.vim`)
- **Dual plugin ecosystems:**
  - Neovim → Modern Lua plugins (telescope, treesitter, native LSP)
  - Vim → Async alternatives (CtrlP, vim-lsp, NERDTree)
- **Entry points:**
  - Neovim: `nvim-init.vim` → sources shared configs
  - Vim: `vim-init.vim` → sources shared configs

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
- `vim-init.vim` - Vim entry point (~/.vimrc symlink target)
- `nvim-init.vim` - Neovim entry point (~/.config/nvim/init.vim symlink target)
- `graphical.vim` - GUI vim settings (~/.gvimrc symlink target)
- `config/` - Shared vim/nvim configuration modules
  - `config/plugins.vim` - Plugin declarations (vim-plug)
  - `config/*.vim` - Feature-specific configs (keybindings, LSP, etc.)
- `ftplugin/` - Filetype-specific settings (symlinked to both ~/.vim/ and ~/.config/nvim/)

### Terminal & Multiplexer
- `.tmux.conf` - Tmux configuration (Ctrl+A prefix, vi-mode, mouse support)
- `kitty.conf` - Kitty terminal emulator config (2,800+ lines: fonts, colors, shortcuts)
- `.inputrc` - Readline configuration for terminal input

### Git Tooling
- `git-completion.bash`, `git-completion.zsh`, `git-prompt.bash` - Downloaded by setup.sh (git-ignored)
- `.tern-config` - Tern (JavaScript tooling) configuration

---

## Tech Stack & Dependencies

### Required
- **Git** - Version control
- **Node.js & npm** - For LSP servers
  - `typescript-language-server`
  - `typescript`
  - `vscode-langservers-extracted` (HTML/CSS/JSON/ESLint)
  - `vim-language-server`

### Recommended
- **Zsh** with oh-my-zsh - Primary shell experience
- **Neovim** - Primary editor (Vim as fallback)
- **Tmux** - Terminal multiplexer
- **Kitty** - Terminal emulator

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

### 2025-11-25
- **Documentation system established:** Created this CLAUDE.md with automatic maintenance instructions. Claude instances should now proactively update documentation as they discover patterns and make changes.
- **Initial context populated:** Extracted key information from README.md to establish baseline understanding of repository structure and purpose.

---

## Notes & Patterns

*(This section for ad-hoc observations that don't fit above categories)*

- **Git branch structure:** Main branch is `master` (not `main`). PRs should target `master`.
- **Leader keys:** Vim/Neovim use `,` (leader) and `;` (local leader) for custom mappings
- **Naming convention:** Config files use lowercase with dashes (`.tmux.conf`, `.bash_profile`)
- **Symlink pattern:** Setup script creates symlinks FROM `.dotfiles/` TO standard locations (not the reverse)
