# Ankit's Dotfiles

Personal configuration files for shell, vim/neovim, tmux, and development tools. Optimized for web development with comprehensive git workflows, modern LSP support, and productivity shortcuts.

**Quick Start:**

```bash
./setup.sh    # Install and configure
./clean.sh    # Uninstall and cleanup
```

## Architecture Overview

This dotfiles repository uses **Dotbot plus focused task scripts** for configuration management:

- **All configs live in `~/.dotfiles/`** and are version-controlled via git
- **Dotbot owns symlinks and cleanup** via `install.conf.yaml`
- **Task scripts handle stateful setup** that Dotbot core cannot express safely
- **Idempotent setup/teardown** - `setup.sh` can be run repeatedly without side effects
- **Dual editor system** - Vim (VimScript + vim-plug) and Neovim (Lua + lazy.nvim) are **distinct, separate configs**

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Symlinks vs Copying** | Changes reflect immediately, easy version control |
| **Pinned Dotbot Bootstrap** | `setup.sh` downloads Dotbot `1.24.1` into `.cache/dotbot/`, verifies SHA256, and never requires submodules or global Dotbot installation |
| **Dotbot Manifest** | `install.conf.yaml` is the readable setup graph for links, cleanup, and task order |
| **Focused Setup Tasks** | `setup/tasks/*.sh` contains stateful behavior like package installation, downloads, and config merges |
| **Vim/Neovim Separation** | Neovim uses modern Lua stack (lazy.nvim, native LSP, 37ms startup). Vim uses VimScript (vim-plug, async plugins). Only `vimconfig/options.vim` and `ftplugin/*.vim` are shared. |
| **Idempotent Setup** | Dotbot manages links declaratively; task scripts use `grep -Fq` substring checks, managed-section replacement, and `mkdir -p` patterns |
| **Layered Shell Sourcing** | `.zshrc`/`.bash_profile` → `.profile` → modular configs |
| **Safety Aliases** | All destructive commands (`mv`/`cp`/`rm`) aliased with `-i` flag |

**For detailed architecture patterns and file mappings, see [AGENTS.md](AGENTS.md).**

---

## Prerequisites

**Required:**

- **Git** - Version control
- **Node.js & npm** - For LSP servers and language tools
- **Homebrew** (macOS) - Package manager for dependencies

**Recommended:**

- **Zsh** with oh-my-zsh - Full shell experience with themes
- **Neovim** - Primary editor (or Vim as fallback)
- **Tmux** - Terminal multiplexer
- **Kitty** or **WezTerm** - Terminal emulator

**Terminal tools (installed via Brewfile):**

- **bat** - Syntax-highlighted cat (used by file picker)
- **fd** - Fast file finder
- **fzf** - Fuzzy finder
- **ripgrep** - Fast grep
- **git-delta** - Syntax-highlighted diffs

**Optional (installed via Brewfile):**

- **Graphite CLI** - Enhanced git workflow for stacked PRs
- **Claude Code** - AI coding assistant
- **1Password CLI** - Password management

---

## Installation

### Quick Setup on New Device

```bash
# 1. Clone repository
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. Run setup script
./setup.sh

# 3. Restart shell
exec $SHELL

# 4. Open vim/neovim (plugins auto-install on first launch)
nvim
```

### What setup.sh Does

`setup.sh` is intentionally small: it bootstraps a pinned, checksum-verified Dotbot release into `.cache/dotbot/`, then delegates to `install.conf.yaml`.

Dotbot then runs the setup graph:

1. **Creates symlinks and cleans managed broken links** from `install.conf.yaml`

2. **Installs Brewfile packages** (macOS only):
   - Core: git, neovim, tmux, node
   - Terminal tools: bat, fd, fzf, git-delta, ripgrep
   - Linters: shellcheck, tflint
   - Apps: wezterm

3. **Installs npm packages globally** (LSP servers from `npm-global-packages.txt`)

4. **Downloads git completion files** from official git repository

5. **Compiles WezTerm terminfo** for proper cursor/undercurl support

6. **Updates shell configs** to source dotfiles

7. **Configures git** by adding an include for this repo's `.gitconfig`

8. **Installs bat Tokyo Night theme** for syntax-highlighted previews

9. **Configures AI tools**:
   - Claude Code hooks, TypeScript plugin, and MCP servers
   - Codex MCP servers and default approval rules

**Idempotency guarantee:** Running `setup.sh` multiple times is safe. Dotbot converges symlinks, and task scripts skip or merge already-completed operations.

### Dotbot Workflow

Useful setup commands:

```bash
./setup.sh                 # Full setup
./setup.sh --dry-run       # Show what Dotbot would do
./setup.sh --only link     # Run only Dotbot link directives
./setup.sh --except shell  # Run links/cleanup without task scripts
```

To update Dotbot:

1. Change `DOTBOT_VERSION` in `setup.sh`.
2. Download the matching release archive from GitHub.
3. Run `shasum -a 256 <archive>`.
4. Update `DOTBOT_SHA256` in `setup.sh`.
5. Run `./setup.sh --dry-run` and `./scripts/verify-setup.sh`.

Dotbot is intentionally not installed globally and this repo intentionally does not use Dotbot plugins or git submodules.

To add setup behavior:

- Add new symlinks under the `link` block in `install.conf.yaml`.
- Add new stateful behavior as a focused executable script in `setup/tasks/`.
- Wire task scripts into the `shell` block in `install.conf.yaml`.
- Keep task scripts runnable directly and idempotent when run more than once.

---

## Symlink Map

| Source (in .dotfiles) | Destination |
| --------------------- | ----------- |
| `.inputrc` | `~/.inputrc` |
| `.lesskey` | `~/.lesskey` |
| `.tern-config` | `~/.tern-config` |
| `.tmux.conf` | `~/.tmux.conf` |
| `USER_PREFERENCES.md` | `~/.claude/CLAUDE.md` (Claude Code) |
| `USER_PREFERENCES.md` | `~/.codex/AGENTS.md` (Codex) |
| `USER_PREFERENCES.md` | `~/.gemini/GEMINI.md` (Gemini) |
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `wezterm/` | `~/.config/wezterm` |
| `init-vim.vim` | `~/.vimrc` |
| `init-gvim.vim` | `~/.gvimrc` |
| `nvim/` | `~/.config/nvim/` (init.lua, plugins/, config/, util/) |
| `vimconfig/`, `ftplugin/` | `~/.vim/` and `~/.config/nvim/` |

Git config is not symlinked directly; `setup/tasks/git-config.sh` adds an `[include]` entry in `~/.gitconfig` that points at this repo's `.gitconfig`, which then includes `themes.gitconfig`.

---

## Configuration Highlights

### Shell (Zsh)

**50+ Git Aliases** (`.zshrc`):
- Common: `co` (checkout), `br` (branch), `st` (status), `dif` (diff)
- Commit: `com`/`cam` (commit), `caam` (amend), `chp` (cherry-pick)
- Log: `lg` (formatted log), `lb` (branch log), `lgm` (my commits)
- Push/Pull: `pushme` (push to origin HEAD), `pullme` (pull from main)
- Rebase: `rem` (rebase main), `rehu` (rebase with --update-refs)

**Safety Features:**
- `mv="mv -i"`, `cp="cp -i"`, `rm="rm -i"` - Interactive mode prompts

**Navigation:**
- `..`, `...`, `....`, `.....` - Go up 1-4 directories
- `l`/`ll`/`ls` - Detailed listing with colors

**Editor:**
- `v`, `vi`, `n` - Launch neovim
- `v.`, `n.` - Open neovim in current directory

**Utilities:**
- `c='clear'`, `rmswaps`, `rebash` (reload shell), `psg` (grep processes)

**For complete keyboard shortcuts, see [KEYBINDINGS.md](KEYBINDINGS.md).**

### AI Tools

**Claude Code** is configured via `claude-settings.json` and `claude-mcp.json`, which `setup/tasks/claude.sh` merges into `~/.claude/settings.json` and `~/.claude.json`.

**Codex** is configured via `codex-mcp.toml` and `codex-rules/default.rules`, which `setup/tasks/codex.sh` merges into `~/.codex/config.toml` and `~/.codex/rules/default.rules`.

**Codex defaults included in this repo:**
- `chrome-devtools`, `notion`, and `figma` MCP servers
- Preapproved `chrome-devtools` MCP tools
- Default allow-rules for common `git`, `gh`, and `gt` commands

### Vim/Neovim

**Leader Keys:** `,` (leader), `;` (local leader)

**Vim and Neovim are DISTINCT configurations** - they do NOT share code:

| Editor | Stack | Entry Point | Keymaps |
|--------|-------|-------------|---------|
| **Neovim** | Lua-first + lazy.nvim (37ms startup) | `nvim/init.lua` | `nvim/config/keymaps.lua` |
| **Vim** | VimScript + vim-plug | `init-vim.vim` | `vimconfig/mappings.vim` |

**Shared:** Only `vimconfig/options.vim` (basic vim options) and `ftplugin/*.vim` (filetype settings)

**Plugin Highlights (Neovim):**
- `fzf-lua` - Fast fuzzy finder (sub-50ms in large repos)
- `snacks.nvim` - QoL collection (bufdelete, terminal, scroll, gitbrowse, lazygit)
- `neo-tree` - File explorer with git_status view
- `treesitter` - Advanced syntax highlighting (20+ parsers)
- `mason` + `mason-lspconfig` - Auto-installs 14 LSP servers
- `typescript-tools` - Direct tsserver (28GB memory for large monorepos)
- `none-ls` - Linters/formatters via LSP (prettier, eslint_d, stylua, shellcheck, etc.)
- `nvim-cmp` - Autocompletion with LSP
- `lsp-lens` - Reference counts above functions
- `claudecode.nvim` - Claude Code integration
- `image.nvim` - View images in terminal (kitty graphics protocol)

**For complete keybindings, see [KEYBINDINGS.md](KEYBINDINGS.md).**

**Full plugin lists:**
- Neovim: `nvim/plugins/*.lua` (split by category: ui, editor, lsp, lang, tools)
- Vim: `vimconfig/plugins.vim`

### Tmux

**Prefix:** `Ctrl+A` (not default `Ctrl+B`)

**Features:**
- Vi mode for copy-mode
- Full mouse support with scroll
- Status bar at top, 256 colors
- Windows start at 1, auto-renumber on close

**Plugin Manager:** Tmux Plugin Manager (tpm)

**For keybindings, see [KEYBINDINGS.md](KEYBINDINGS.md).**

### Terminal Emulators

#### WezTerm (Recommended)

Lua-based configuration in `wezterm/wezterm.lua`:

- **Theme:** Tokyo Night
- **Font:** FantasqueSansM Nerd Font Mono (14pt)
- **Performance:** WebGPU acceleration, 120fps animations
- **Scrollback:** 10,000 lines
- **Transparency:** 90% opacity with blur (macOS)

**For complete keybindings, see [KEYBINDINGS.md](KEYBINDINGS.md).**

#### Kitty

Comprehensive configuration (2,800+ lines) in `kitty.conf` with custom fonts, color scheme, and keyboard shortcuts.

---

## Cleanup/Uninstall

```bash
./clean.sh
```

**What clean.sh does:**
- Removes symlinks created by setup
- Cleans git completion files
- Removes vim/neovim configuration directories
- Prompts to manually clean shell config files

---

## Maintenance

### Updating Plugins

**Neovim:** `:Lazy update`

**Vim:** `:PlugUpdate`

### Updating Dotfiles

```bash
cd ~/.dotfiles
git pull
```

### Adding New Configurations

1. Edit files in `~/.dotfiles/` (changes reflect immediately via symlinks)
2. Add symlinks to `install.conf.yaml` or focused setup behavior to `setup/tasks/`
3. Test setup changes:
   ```bash
   ./setup.sh --dry-run
   ./scripts/verify-setup.sh
   ./scripts/test-setup-fixtures.sh
   ```
4. Test editor/shell changes: `rebash` (shell), `,r` (vim/neovim)
5. Commit and push:
   ```bash
   git add .
   git commit -m "Add feature X"
   git push
   ```

### Syncing Across Devices

**On device with changes:**
```bash
cd ~/.dotfiles && git push
```

**On other devices:**
```bash
cd ~/.dotfiles && git pull
```

---

## Troubleshooting

For common issues and solutions, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**.

**Quick FAQ:**

**Q: Plugins not installing?**
A: Neovim: `:Lazy`, `:Lazy health` | Vim: `:PlugInstall`

**Q: Shell aliases not working?**
A: Run `exec $SHELL` or `source ~/.zshrc`

**Q: LSP not working?**
A: Check `:LspInfo`, verify npm packages: `npm list -g | grep language-server`

**Q: Tmux prefix not Ctrl+A?**
A: Reload config: `tmux source-file ~/.tmux.conf` or restart tmux

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

## Documentation

This repository includes specialized documentation files:

- **[AGENTS.md](AGENTS.md)** - AI-optimized context (architecture, file mappings, tech stack)
- **[CHANGELOG.md](CHANGELOG.md)** - Historical changes and discoveries
- **[KEYBINDINGS.md](KEYBINDINGS.md)** - Complete keyboard shortcuts reference
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[USER_PREFERENCES.md](USER_PREFERENCES.md)** - User-level preferences (Claude Code)

---

**Config File Locations:**

- Shell: `.zshrc`, `.profile`, `.bash_prompt`, `.inputrc`
- Git: `.gitconfig`, `themes.gitconfig`
- Neovim: `nvim/` (Lua), `vimconfig/options.vim` (shared)
- Vim: `vimconfig/` (VimScript)
- Filetypes: `ftplugin/*.vim` (shared)
- Tmux: `.tmux.conf`
- Terminal: `kitty.conf`, `wezterm/`
- Setup: `setup.sh`, `install.conf.yaml`, `setup/tasks/`
- Scripts: `scripts/`, `clean.sh`
