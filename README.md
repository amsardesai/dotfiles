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

**Recommended:**
- **Zsh** with oh-my-zsh - Full shell experience with themes
- **Neovim** - Primary editor (or Vim as fallback)
- **Tmux** - Terminal multiplexer
- **Kitty** or **WezTerm** - Terminal emulator

**Optional:**
- **git-delta** - Syntax-highlighted diffs (used as git pager)
- Graphite CLI - Enhanced git workflow
- LM Studio CLI - Local LLM integration
- 1Password CLI - Password management

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

1. **Downloads git completion files** from official git repository
   - git-completion.bash, git-completion.zsh, git-prompt.bash

2. **Installs npm packages globally:**
   - `typescript-language-server`
   - `typescript`
   - `vscode-langservers-extracted`
   - `vim-language-server`

3. **Creates symlinks** to dotfiles:
   - Shell: `.inputrc`
   - Terminal: `.tmux.conf`, `kitty.conf`, `wezterm/`
   - Editors: vim and nvim configurations
   - Git: completion scripts

4. **Updates shell configs** to source dotfiles:
   - Adds source line to `~/.bash_profile` (bash)
   - Adds source line to `~/.zshrc` (zsh)

**Optimization behavior:**
- Skips npm package installation if all packages are already installed
- Skips downloading git completion files if they already exist
- Re-running setup.sh is fast and safe

### Symlink Map

| Source (in .dotfiles) | Destination |
|----------------------|-------------|
| `.inputrc` | `~/.inputrc` |
| `.tern-config` | `~/.tern-config` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.gitconfig` | `~/.gitconfig` |
| `themes.gitconfig` | `~/.themes.gitconfig` |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `wezterm/` | `~/.config/wezterm` |
| `vim-init.vim` | `~/.vimrc` |
| `gvim-init.vim` | `~/.gvimrc` |
| `nvim-init.vim` | `~/.config/nvim/init.vim` |
| `config/`, `ftplugin/` | `~/.vim/` and `~/.config/nvim/` |

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

### Vim/Neovim Setup

**Philosophy:** Shared config with dual plugin ecosystems. Neovim uses modern Lua plugins (telescope, treesitter, LSP), while Vim uses async alternatives.

**Leader Keys:**
- Leader: `,`
- Local Leader: `;`

**Essential Keybindings:**

| Category | Keybinding | Action |
|----------|------------|--------|
| **Buffer Management** | `,]` | Next buffer |
| | `,[` | Previous buffer |
| | `,\` | Close buffer |
| **Fuzzy Finder** | `<C-p>` | Find files |
| | `<C-o>` | Live grep |
| | `<C-i>` | Grep for string |
| **File Explorer** | `,m` | Toggle file tree |
| | `,n` | Find current file |
| | `,b` | Open tree |
| **LSP** | `K` | Hover documentation |
| | `gd` | Go to definition |
| | `gr` | Find references |
| | `gi` | Go to implementation |
| | `<F2>` | Rename symbol |
| | `<F3>` | Format document |
| | `<F4>` | Code actions |
| **Terminal** | `,z` | Open terminal (horizontal split) |
| | `,x` | Close terminal |
| | `;;q` / `<ESC><ESC>` | Exit terminal mode |
| **Git** | `(` | Previous hunk |
| | `)` | Next hunk |
| | `,gb` | Git blame |
| **Context Menu** | `<RightMouse>` | Open context menu (LSP, Git, File ops) |
| **Pane Navigation** | `Shift+Arrows` | Move between splits (all modes) |
| **Utilities** | `<CR>` | Clear search highlight |
| | `,fw` | Fix whitespace |
| | `,rs` | Reload vim config |

**Plugin Highlights:**

*Shared (Vim & Neovim):*
- `auto-pairs` - Auto-close brackets
- `nerdcommenter` - Toggle comments
- `vim-surround` - Manipulate surrounding delimiters
- `vim-sneak` - Fast motion search
- `prettier` - Code formatting

*Neovim-specific:*
- `nvim-tree` - File explorer
- `telescope` - Fuzzy finder with ui-select extension
- `treesitter` - Advanced syntax highlighting (20+ parsers)
- `lualine` - Status line
- `mason` + `mason-lspconfig` - Auto-installs 14 LSP servers
- `nvim-lspconfig` - LSP configuration
- `nvim-cmp` - Autocompletion
- `toggleterm` - Integrated terminal

*Vim-specific:*
- `NERDTree` - File explorer
- `CtrlP` - Fuzzy finder
- `vim-airline` - Status line
- `vim-lsp` - LSP support

**Full plugin list:** See `config/plugins.vim`

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
- **Theme:** Dracula color scheme
- **Font:** FantasqueSansM Nerd Font Mono (14pt)
- **Performance:** WebGPU acceleration, 60fps animations
- **Scrollback:** 10,000 lines
- **Keybindings:** CMD-based (macOS-friendly) - pane splitting (CMD+D), tab navigation, pane movement

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
**Solutions:**
- Manually run `:PlugInstall` inside vim/neovim
- Check network connection (downloads from GitHub)
- Verify vim-plug installed: `ls ~/.vim/autoload/plug.vim` or `~/.config/nvim/autoload/plug.vim`

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

**Vim/Neovim:**
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
- Vim/Neovim: `config/*.vim`, `ftplugin/*.vim`
- Tmux: `.tmux.conf`
- Terminal: `kitty.conf`, `wezterm/`
- Scripts: `setup.sh`, `clean.sh`
