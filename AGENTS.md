# Dotfiles - AI Context & Quick Reference

> **AI-SPECIFIC DOCUMENTATION**
>
> This file contains AI-optimized context for Claude Code. For human-readable docs, see README.md.
>
> **Auto-update this file** when you discover:
> - Architecture patterns, design decisions
> - Key file/directory mappings
> - Tech stack changes, new dependencies
> - Important conventions, naming patterns
>
> **⚠️ PUBLIC REPOSITORY**
> - NEVER add credentials, API keys, tokens, passwords
> - NEVER add internal IPs, hostnames, sensitive URLs
> - NEVER add proprietary code or confidential information
>
> **Documentation Structure:**
> - `AGENTS.md` (this file) → AI context, architecture, file mappings
> - `CHANGELOG.md` → Historical changes and discoveries
> - `README.md` → Human-facing setup and features
> - `KEYBINDINGS.md` → Keyboard shortcuts reference
> - `TROUBLESHOOTING.md` → Common issues and solutions
> - `USER_PREFERENCES.md` → User-level preferences (~/.claude/CLAUDE.md)

---

## Quick Reference

### Critical Rules

| Rule | Details |
|------|---------|
| **Idempotency** | `setup.sh` MUST work identically run 1x or 1000x. Use `grep -Fq` (substring), NOT `grep -Fxq` (whole line) |
| **Unicode** | Preserve box-drawing chars: `│ ─ ┌ └ ├ ┤ ┬ ┴ ┼` - NEVER replace with ASCII `\| - +` |
| **Vim/Neovim** | Distinct configs, NOT sharing code. Neovim=Lua+lazy.nvim, Vim=VimScript+vim-plug |
| **Leader Keys** | `,` (leader), `;` (local leader) |
| **Git Branch** | `main` is primary branch |

### Repository Overview

| Aspect | Details |
|--------|---------|
| **Purpose** | Personal dotfiles for shell, vim/neovim, tmux, terminal emulators, git |
| **Owner** | Ankit Sardesai (Notion - web perf/a11y/DX) |
| **Strategy** | Symlink-based, version controlled, idempotent setup/teardown scripts |
| **Main Branch** | `main` |
| **Setup** | `./setup.sh` → symlinks to `~`, downloads deps, updates shell configs |
| **Cleanup** | `./clean.sh` → removes all symlinks |

---

## Architecture Patterns

### Configuration Strategy

| Pattern | Implementation |
|---------|----------------|
| **Symlinks** | FROM `~/.dotfiles/` TO standard locations (`~/.vimrc`, `~/.config/nvim/`, etc.) |
| **Version Control** | Entire `~/.dotfiles/` is a git repo |
| **Idempotency** | Check before change, `ln -sfn`, `mkdir -p`, `grep -Fq` (substring match) |
| **Shell Sourcing** | `.zshrc`/`.bash_profile` → `.profile` → modular configs |
| **Safety** | All destructive commands (`mv`/`cp`/`rm`) aliased with `-i` flag |

### Editor Philosophy

**Vim and Neovim are DISTINCT - not sharing code:**

| Editor | Stack | Entry Point | Keymaps | Plugins |
|--------|-------|-------------|---------|---------|
| **Neovim** | Lua-first + lazy.nvim | `nvim/init.lua` | `nvim/config/keymaps.lua` | fzf-lua, treesitter, native LSP, snacks.nvim, typescript-tools |
| **Vim** | VimScript + vim-plug | `init-vim.vim` | `vimconfig/mappings.vim` | CtrlP, vim-lsp, NERDTree, nerdcommenter, vim-airline |

**Shared between both:** Only `vimconfig/options.vim` (basic options) and `ftplugin/*.vim` (filetype settings)

**Neovim load sequence:** `nvim/init.lua` → bootstrap lazy.nvim → `nvim/plugins/*.lua` → `vimconfig/main.vim` (options only) → `nvim/config/*.lua`

**Vim load sequence:** `init-vim.vim` → `vimconfig/main.vim` (full config with plugins, options, mappings)

---

## File Mappings

### Entry Points

| File | Purpose | Symlink Target |
|------|---------|----------------|
| `setup.sh` | Install script (deps, symlinks, shell configs) | - |
| `clean.sh` | Uninstall script (remove symlinks) | - |
| `.profile` | Main shell config (bash & zsh) | `~/.profile` |
| `.zshrc` | Zsh-specific (git aliases, oh-my-zsh) | Sources `~/.dotfiles/.zshrc` |
| `init-vim.vim` | Vim entry point | `~/.vimrc` |
| `nvim/init.lua` | Neovim entry point | `~/.config/nvim/init.lua` |

### Neovim Structure (LazyVim-style)

| Path | Contents |
|------|----------|
| `nvim/plugins/` | lazy.nvim specs split by category (ui, editor, lsp, lang, tools) |
| `nvim/config/` | Global settings (options.lua, keymaps.lua) |
| `nvim/util/` | Utilities (file_cache, context_menu, bottom_drawers) |

### Vim Structure

| Path | Contents |
|------|----------|
| `vimconfig/main.vim` | Entry point (sources plugins, options, mappings) |
| `vimconfig/plugins.vim` | vim-plug declarations (Vim-only) |
| `vimconfig/options.vim` | Shared with Neovim |
| `vimconfig/mappings.vim` | Vim-only (has `if has('nvim') finish endif` guard) |

### Terminal & Git

| File | Purpose | Symlink Target |
|------|---------|----------------|
| `.tmux.conf` | Tmux (Ctrl+A prefix, vi-mode) | `~/.tmux.conf` |
| `kitty.conf` | Kitty emulator (2,800+ lines) | `~/.config/kitty/kitty.conf` |
| `wezterm/` | WezTerm config directory | `~/.config/wezterm` |
| `.gitconfig` | Git config (delta pager, merge settings) | `~/.gitconfig` |
| `themes.gitconfig` | Delta theme (gruvmax-fang Gruvbox) | `~/.themes.gitconfig` |
| `.lesskey` | Less pager (env + keybindings) | `~/.lesskey` |

---

## Tech Stack

### Required

- **Git** - Version control
- **Node.js + npm** - LSP servers: `typescript-language-server`, `vscode-langservers-extracted`, `vim-language-server`

### Recommended

- **Zsh** (oh-my-zsh) - Primary shell
- **Neovim** 0.9.0+ - Primary editor (Vim fallback)
- **Tmux** - Multiplexer
- **WezTerm** or **Kitty** - Terminal emulator
- **bat**, **fd**, **fzf**, **git-delta**, **ripgrep** - CLI enhancements

### Package Managers

| Manager | Purpose | Notable |
|---------|---------|---------|
| **lazy.nvim** | Neovim plugins (Lua-based, lazy-loading) | 37ms startup time |
| **vim-plug** | Vim plugins (auto-install on first launch) | - |
| **Mason** | LSP/linter/formatter installer (Neovim) | Auto-installs: cssls, html, jsonls, lua_ls, pylsp, etc. |
| **none-ls** | Linters & formatters via LSP | eslint_d, prettier, shellcheck, stylua, etc. |
| **Homebrew** | macOS packages | Declarative via `Brewfile` |
| **npm** | Global packages | LSP servers (see `npm-global-packages.txt`) |

### Brewfile (macOS)

**Core:** git, neovim, tmux, node
**CLI:** bat, fd, fzf, git-delta, ripgrep, shellcheck, tflint, imagemagick
**GUI:** wezterm

---

## Development Workflows

### Setup New Machine

```bash
git clone <repo> ~/.dotfiles
cd ~/.dotfiles
./setup.sh           # Downloads deps, creates symlinks, updates shell configs
exec $SHELL          # Restart shell
nvim                 # Plugins auto-install
```

### Make Changes

1. Edit files in `~/.dotfiles/` (changes reflect immediately via symlinks)
2. Test: `rebash` (shell), `,r` (vim/neovim), `Ctrl+A :source` (tmux)
3. Commit & push
4. Other devices: `cd ~/.dotfiles && git pull`

### Common Operations

| Task | Command |
|------|---------|
| **Update plugins** | Neovim: `:Lazy update`, Vim: `:PlugUpdate` |
| **Reload config** | Shell: `rebash`, Vim/Neovim: `,r`, Tmux: `Ctrl+A :source-file ~/.tmux.conf` |
| **Clean install** | `./clean.sh` then `./setup.sh` |
| **Check LSP status** | Neovim: `:LspInfo`, Vim: `:LspStatus` |
| **Restart LSP** | Neovim: `,rl` or `:LspRestart` |

---

## Notes & Patterns

**Critical Conventions:**

- **Idempotency:** `setup.sh` must work identically 1x or 1000x
  - Check before making changes
  - Use `grep -Fq` (substring), NOT `grep -Fxq` (whole line)
  - Never append without checking if content exists
  - See `setup.sh` header for full rules

- **Unicode Preservation:** Repository uses `│ ─ ┌ └ ├ ┤ ┬ ┴ ┼` (box-drawing chars)
  - LLMs frequently replace with ASCII `| - +` - **DON'T DO THIS**
  - Always preserve exact Unicode characters

- **Vim/Neovim Separation:** Distinct configs, NOT sharing code
  - Neovim = Lua + lazy.nvim
  - Vim = VimScript + vim-plug
  - Don't try to make them compatible

- **Git Branch:** `main` is primary, PRs target `main`

- **Leader Keys:** `,` (leader), `;` (local leader)

- **Naming:** Config files use lowercase with dashes (`.tmux.conf`, `.bash_profile`)

- **Symlink Direction:** FROM `.dotfiles/` TO standard locations (not reverse)

---

## Documentation Index

For detailed information, see specialized documentation files:

- **CHANGELOG.md** - Historical changes and discoveries (extracted from this file)
- **KEYBINDINGS.md** - All keyboard shortcuts across tools (Neovim, Tmux, WezTerm, Shell, Less)
- **TROUBLESHOOTING.md** - Common issues and solutions
- **README.md** - Human-facing setup instructions and feature overview
- **USER_PREFERENCES.md** - User-level preferences (symlinked to ~/.claude/CLAUDE.md)
