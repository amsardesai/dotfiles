# Ankit's Dotfiles

Personal configuration files for shell, vim/neovim, tmux, and development tools. Optimized for web development with comprehensive git workflows, modern LSP support, and productivity shortcuts.

**Quick Start:**

```bash
./setup.sh    # Install and configure
./clean.sh    # Uninstall and cleanup
```

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

1. **Installs Brewfile packages** (macOS only):
   - Core: git, neovim, tmux, node
   - Terminal tools: bat, fd, fzf, git-delta, ripgrep
   - Linters: shellcheck, tflint
   - Apps: wezterm

2. **Downloads git completion files** from official git repository
   - git-completion.bash, git-completion.zsh, git-prompt.bash

3. **Installs npm packages globally** (from `npm-global-packages.txt`):
   - `typescript-language-server`, `typescript`
   - `vscode-langservers-extracted`
   - `vim-language-server`

4. **Compiles WezTerm terminfo** for proper cursor/undercurl support

5. **Installs bat Tokyo Night theme** for syntax-highlighted previews

6. **Creates symlinks** to dotfiles:
   - Shell: `.inputrc`, `.markdownlintrc`
   - Terminal: `.tmux.conf`, `kitty.conf`, `wezterm/`
   - Editors: vim (`vimconfig/`) and nvim (`nvim/`) configurations
   - Claude: `.claude/CLAUDE.md`

7. **Updates shell configs** to source dotfiles:
   - Adds source line to `~/.bash_profile` (bash)
   - Adds source line to `~/.zshrc` (zsh)

**Idempotency guarantee:**

> **setup.sh is fully idempotent.** Running it 1 time or 1000 times produces the same result.

- Skips Brewfile packages if already installed
- Skips npm packages if already installed
- Skips downloads if files already exist
- Skips symlinks if already pointing to correct target
- Skips shell config updates if source line already present
- Re-running setup.sh is fast and safe (~5 seconds)

### Symlink Map

| Source (in .dotfiles) | Destination |
| --------------------- | ----------- |
| `.inputrc` | `~/.inputrc` |
| `.lesskey` | `~/.lesskey` |
| `.tern-config` | `~/.tern-config` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.gitconfig` | `~/.gitconfig` |
| `themes.gitconfig` | `~/.themes.gitconfig` |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `wezterm/` | `~/.config/wezterm` |
| `init-vim.vim` | `~/.vimrc` |
| `init-gvim.vim` | `~/.gvimrc` |
| `init-nvim.lua` | `~/.config/nvim/init.lua` |
| `vimconfig/`, `ftplugin/`, `nvim/` | `~/.vim/` and `~/.config/nvim/` |

## Post-Install Checklist

After running setup, verify:

- [ ] **Shell sources dotfiles:** Test with `v` (should launch neovim)
- [ ] **Vim/Neovim plugins installed:** First launch runs `:PlugInstall` automatically
- [ ] **Git completion working:** Type `git <TAB>` to test
- [ ] **LSP servers available:** Run `npm list -g | grep language-server`
- [ ] **Tmux prefix changed:** Prefix is `Ctrl+A` (not default `Ctrl+B`)

## Configuration Overview

### Shell Configuration

**Git Aliases** (50+ shortcuts in `.zshrc`):

- Common: `co` (checkout), `br` (branch), `st` (status), `dif` (diff with smart options)
- Commit: `com`/`cam` (commit), `caam` (amend no-edit), `chp` (cherry-pick)
- Log: `lg` (formatted log), `lb` (branch log), `lgm` (my commits)
- Push/Pull: `pushme` (push to origin HEAD), `pullme` (pull from main)
- Rebase: `rem` (rebase main), `rehu` (rebase with --update-refs)
- **See `.zshrc` for complete list**

**Safety Aliases:**

- `mv="mv -i"`, `cp="cp -i"`, `rm="rm -i"` - Interactive mode prompts

**Navigation Shortcuts:**

- `..`, `...`, `....`, `.....` - Go up 1-4 directories
- `l`/`ll`/`ls` - Detailed listing with colors (`ls -alFh`)

**Editor Shortcuts:**

- `v`, `vi`, `n` - Launch neovim
- `v.`, `n.` - Open neovim in current directory

**Utilities:**

- `c='clear'` - Clear screen
- `rmswaps` - Remove vim swap files
- `rebash` - Reload shell config
- `psg` - Grep processes

**Less Pager Keybindings** (via `.lesskey`):

| Key | Action |
| --- | ------ |
| `_` | Page up |
| `+` | Page down |
| `{` | Half page up |
| `}` | Half page down |

### Vim/Neovim Setup

**Philosophy:** Vim and Neovim have **distinct, separate configurations**:

- **Neovim:** Full Lua-first stack with **lazy.nvim** (lazy-loading, 37ms startup). All keymaps in `nvim/config/keymaps.lua`, plugins in `nvim/plugins/*.lua`.
- **Vim:** VimScript with **vim-plug**. All keymaps in `vimconfig/mappings.vim`, plugins in `vimconfig/plugins.vim`.

They are NOT trying to share code - only `vimconfig/options.vim` (basic options) and `ftplugin/*.vim` (filetype settings) are used by both.

**Leader Keys:**

- Leader: `,`
- Local Leader: `;`

**Essential Keybindings:**

| Category | Keybinding | Action |
| -------- | ---------- | ------ |
| **Buffer Management** | `,]` | Next buffer |
| | `,[` | Previous buffer |
| | `,bd` | Delete buffer (preserves layout) |
| **Fuzzy Finder (fzf-lua)** | `<C-p>` | Find files (cached, instant) |
| | `<C-o>` | Live grep |
| | `,ll` | Find files |
| | `,lk` | Live grep |
| | `,lj` | Grep word under cursor |
| | `,lr` | Refresh file cache |
| **File Explorer** | `,m` | Toggle file tree (no focus) |
| | `,n` | Focus tree & reveal file |
| | `,b` | Show tree (no focus) |
| | `,g` | Toggle git status view |
| **LSP** | `K` | Hover documentation |
| | `gd` | Go to definition |
| | `gr` | Find references |
| | `gi` | Go to implementation |
| | `<F2>` | Rename symbol |
| | `<F3>` | Format document |
| | `<F4>` | Code actions |
| | `gh` | Toggle inlay hints |
| | `gL` | Toggle LSP lens |
| | `<C-LeftMouse>` | Go to definition (like VS Code) |
| **Bottom Drawers** | `,z` | Toggle Terminal Z (blue) |
| | `,x` | Toggle Terminal X (purple) |
| | `,t` | Toggle Diagnostics (red) |
| | `,q` | Close all drawers |
| | `,Q` | Kill all terminals |
| **Claude Code** | `,a` | Toggle Claude Code terminal |
| | `,sa` | Add file to Claude context |
| **Git** | `(` | Previous hunk |
| | `)` | Next hunk |
| | `,gb` | Git blame |
| | `,go` | Open in GitHub |
| | `[[` / `]]` | Prev/next reference |
| **Context Menu** | `<RightMouse>` | Open context menu (LSP, Git, File ops) |
| **Diagnostics** | `gl` | Show diagnostic float |
| | `[d` / `]d` | Prev/next diagnostic |
| **Pane Navigation** | `Shift+Arrows` | Move between splits (all modes) |
| | `Option+Shift+Arrows` | Move between splits (alternative) |
| **Utilities** | `<CR>` | Clear search highlight |
| | `,fw` | Fix whitespace |
| | `,r` | Reload config |
| | `,rn` | Rename file (with LSP) |

**Plugin Highlights:**

*Neovim-specific (Lua):*

- `Comment.nvim` - Treesitter-aware commenting (`<leader>c`)
- `nvim-surround` - Surround manipulation (`cs`, `ds`, `ys`)
- `flash.nvim` - Jump anywhere with labels (`s`/`S`)
- `nvim-autopairs` - Auto-close brackets
- `mini.trailspace` - Highlight trailing whitespace
- `fzf-lua` - Fast fuzzy finder
- `snacks.nvim` - QoL collection (bufdelete, terminal, scroll, indent, rename, gitbrowse)
- `neo-tree` - File explorer with git_status view
- `trouble.nvim` - Diagnostics drawer
- `treesitter` - Advanced syntax highlighting (20+ parsers)
- `lualine` - Status line with LSP status
- `bufferline` - Tab bar with diagnostics
- `mason` + `mason-lspconfig` - Auto-installs 14 LSP servers
- `typescript-tools` - Direct tsserver (faster than ts-language-server)
- `none-ls` - Linters/formatters via LSP (prettier, eslint_d, biome, stylua, etc.)
- `nvim-cmp` - Autocompletion
- `lsp-lens` - Reference counts above functions
- `image.nvim` - View images in terminal
- `claudecode.nvim` - Claude Code integration

*Vim-specific (VimScript):*

- `nerdcommenter` - Toggle comments
- `vim-surround` - Surround manipulation
- `auto-pairs` - Auto-close brackets
- `NERDTree` - File explorer
- `CtrlP` - Fuzzy finder
- `vim-airline` - Status line
- `vim-lsp` - LSP support

**Full plugin list:**
- Neovim: See `nvim/plugins/*.lua` (split by category: ui, editor, lsp, lang, tools)
- Vim: See `vimconfig/plugins.vim`

### Tmux Configuration

**Key Settings:**

- **Prefix:** `Ctrl+A` (unbinds default `Ctrl+B`)
- **Vi mode:** Enabled for copy-mode
- **Mouse support:** Full mouse integration with scroll
- **Visual:** Status bar at top, 256 colors, custom formatting
- **Base index:** Windows start at 1 (not 0)
- **Auto-renumber:** Windows renumber on close

**Plugin Manager:** Tmux Plugin Manager (tpm)

### Terminal Emulators

#### Kitty

Comprehensive configuration (2,800+ lines) in `kitty.conf`:

- Custom fonts and symbol mappings
- Color scheme
- Keyboard shortcuts
- Window management

#### WezTerm

Lua-based configuration in `wezterm/` directory. Main config is `wezterm/wezterm.lua`.
The entire directory is symlinked to support additional themes, plugins, and helper files.

**Key Features:**

- **Theme:** Tokyo Night
- **Font:** FantasqueSansM Nerd Font Mono (14pt)
- **Performance:** WebGPU acceleration, 120fps animations (ProMotion)
- **Scrollback:** 10,000 lines
- **Transparency:** 90% opacity with blur (macOS)

**Keybindings (macOS-friendly):**

| Keybinding | Action |
| ---------- | ------ |
| `CMD+D` | Split horizontal |
| `CMD+SHIFT+D` | Split vertical |
| `CMD+SHIFT+Arrows` | Navigate panes |
| `CMD+W` | Close pane |
| `CMD+T` | New tab |
| `CMD+SHIFT+[/]` | Navigate tabs |
| `CMD+ALT+Arrows` | Navigate tabs |
| `CMD+SHIFT+S` | Swap pane (select mode) |
| `CMD+SHIFT+Return` | Toggle pane zoom |
| `CMD+F` | Search scrollback |
| `CMD+SHIFT+X` | Copy mode (vim navigation) |
| `CMD+K` | Clear scrollback |
| `CMD+SHIFT+Space` | Quick select (git hashes, UUIDs) |

## Cleanup/Uninstall

```bash
./clean.sh
```

**What clean.sh does:**

- Removes all symlinks created by setup.sh
- Cleans git completion files (git-ignored)
- Removes vim/neovim configuration directories
- Prompts to manually clean shell config files

## Troubleshooting

### Plugins not installing in vim/neovim

**Symptoms:** Empty editor, missing commands

**Solutions for Neovim (lazy.nvim):**

- Run `:Lazy` to open the plugin manager UI
- Check `:Lazy health` for issues
- Clear cache: `rm -rf ~/.local/share/nvim/lazy` and restart

**Solutions for Vim (vim-plug):**

- Manually run `:PlugInstall` inside vim
- Check network connection (downloads from GitHub)
- Verify vim-plug installed: `ls ~/.vim/autoload/plug.vim`

### Shell aliases not working

**Symptoms:** `v` command not found, git aliases don't work

**Solutions:**

- Verify shell sources dotfiles: `grep dotfiles ~/.zshrc` or `~/.bash_profile`
- Restart shell: `exec $SHELL`
- Manually source: `source ~/.zshrc`

### LSP not working in neovim

**Symptoms:** No autocomplete, no go-to-definition

**Solutions:**

- Check npm packages: `npm list -g | grep language-server`
- Run `:LspInfo` (neovim) or `:LspStatus` (vim) to see server status
- Check Mason installation (neovim): `:Mason`
- Reinstall language servers: `npm install -g typescript-language-server`

### Git completion not working

**Symptoms:** Tab completion doesn't work for git commands

**Solutions:**

- Verify completion files exist: `ls ~/.dotfiles/git-completion.*`
- Check `.profile` sources them correctly
- Restart shell
- Manually re-run setup: `./setup.sh`

### Tmux prefix not Ctrl+A

**Symptoms:** `Ctrl+B` still works, `Ctrl+A` doesn't

**Solutions:**

- Verify symlink: `ls -la ~/.tmux.conf` (should point to dotfiles)
- Reload tmux config: `tmux source-file ~/.tmux.conf`
- Restart tmux completely: exit all sessions and relaunch

### Permission errors during setup

**Symptoms:** setup.sh fails with permission denied

**Solutions:**

- Check write permissions in home directory
- Remove existing symlink destinations manually if they exist
- Ensure script is executable: `chmod +x setup.sh`

## Maintenance

### Updating Plugins

**Neovim (lazy.nvim):**

```vim
:Lazy update
```

**Vim (vim-plug):**

```vim
:PlugUpdate
```

**Shell/Config:**

```bash
cd ~/.dotfiles
git pull
```

### Adding New Configurations

1. Edit files in `~/.dotfiles/`
2. Changes automatically reflected (symlinked)
3. Commit changes:

   ```bash
   git add .
   git commit -m "Add feature X"
   git push
   ```

### Syncing Across Devices

**On device with changes:**

```bash
cd ~/.dotfiles
git push
```

**On other devices:**

```bash
cd ~/.dotfiles
git pull
```

---

**Config File Locations:**

- Shell: `.zshrc`, `.profile`, `.bash_prompt`, `.inputrc`
- Git: `.gitconfig`, `themes.gitconfig`
- Neovim: `nvim/` (Lua), `vimconfig/options.vim` (shared options)
- Vim: `vimconfig/` (VimScript)
- Filetypes: `ftplugin/*.vim` (shared)
- Tmux: `.tmux.conf`
- Terminal: `kitty.conf`, `wezterm/`
- Scripts: `setup.sh`, `clean.sh`
