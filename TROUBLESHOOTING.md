# Troubleshooting Guide

Common issues and solutions for dotfiles setup and usage.

---

## Plugins Not Installing in Vim/Neovim

**Symptoms:**
- Empty editor
- Missing commands
- Plugins don't appear to be loaded

### For Neovim (lazy.nvim)

**Solutions:**
1. **Check plugin manager UI:**
   - Run `:Lazy` to open the plugin manager
   - Look for failed installations or errors

2. **Check health:**
   - Run `:Lazy health` to diagnose issues
   - Follow recommended fixes

3. **Clear cache and reinstall:**
   ```bash
   rm -rf ~/.local/share/nvim/lazy
   ```
   - Restart Neovim (plugins will auto-install)

### For Vim (vim-plug)

**Solutions:**
1. **Manually trigger installation:**
   - Run `:PlugInstall` inside Vim

2. **Check network connection:**
   - Plugins download from GitHub
   - Verify internet connectivity

3. **Verify vim-plug is installed:**
   ```bash
   ls ~/.vim/autoload/plug.vim
   ```
   - If missing, run `./setup.sh` again

---

## Shell Aliases Not Working

**Symptoms:**
- `v` command not found
- Git aliases don't work (e.g., `co`, `br`, `st`)
- Shell appears to not have loaded dotfiles

**Solutions:**

1. **Verify shell sources dotfiles:**
   ```bash
   grep dotfiles ~/.zshrc    # for zsh
   grep dotfiles ~/.bash_profile  # for bash
   ```
   - Should see a line like: `source ~/.dotfiles/.zshrc`

2. **Restart shell:**
   ```bash
   exec $SHELL
   ```

3. **Manually source dotfiles:**
   ```bash
   source ~/.zshrc     # for zsh
   source ~/.profile   # for bash
   ```

4. **Re-run setup if needed:**
   ```bash
   cd ~/.dotfiles
   ./setup.sh
   ```

---

## LSP Not Working in Neovim

**Symptoms:**
- No autocomplete
- No go-to-definition
- No hover documentation
- LSP commands don't work

**Solutions:**

1. **Check LSP server status:**
   - Neovim: Run `:LspInfo` to see attached servers
   - Vim: Run `:LspStatus`

2. **Verify npm packages installed:**
   ```bash
   npm list -g | grep language-server
   ```
   - Should see: `typescript-language-server`, `vscode-langservers-extracted`, `vim-language-server`

3. **Check Mason (Neovim only):**
   - Run `:Mason` to see installed/available servers
   - Install missing servers from the UI

4. **Reinstall language servers:**
   ```bash
   npm install -g typescript-language-server typescript vscode-langservers-extracted vim-language-server
   ```

5. **Restart LSP servers (Neovim):**
   - Press `,rl` to restart all LSP servers
   - Or run `:LspRestart`

6. **Check for errors:**
   - Run `:messages` to see error logs
   - Check `~/.local/state/nvim/lsp.log` (Neovim)

---

## Git Completion Not Working

**Symptoms:**
- Tab completion doesn't work for git commands
- Pressing TAB after `git ` doesn't show suggestions

**Solutions:**

1. **Verify completion files exist:**
   ```bash
   ls ~/.dotfiles/git-completion.*
   ```
   - Should see: `git-completion.bash`, `git-completion.zsh`

2. **Check .profile sources them:**
   ```bash
   grep git-completion ~/.profile
   ```
   - Should see sourcing lines for completion scripts

3. **Restart shell:**
   ```bash
   exec $SHELL
   ```

4. **Re-run setup:**
   ```bash
   cd ~/.dotfiles
   ./setup.sh
   ```
   - This will re-download completion files if missing

---

## Tmux Prefix Not Ctrl+A

**Symptoms:**
- Default `Ctrl+B` still works
- Custom `Ctrl+A` prefix doesn't respond

**Solutions:**

1. **Verify tmux config symlink:**
   ```bash
   ls -la ~/.tmux.conf
   ```
   - Should point to: `~/.dotfiles/.tmux.conf`

2. **Reload tmux configuration:**
   - Inside tmux: `Ctrl+A :source-file ~/.tmux.conf`
   - Or from shell: `tmux source-file ~/.tmux.conf`

3. **Restart tmux completely:**
   - Exit all tmux sessions
   - Kill tmux server: `tmux kill-server`
   - Start fresh: `tmux`

4. **Check for conflicting tmux configs:**
   ```bash
   # Look for system-wide config
   ls /etc/tmux.conf

   # Look for other local configs
   ls ~/.config/tmux/tmux.conf
   ```

---

## Permission Errors During Setup

**Symptoms:**
- `setup.sh` fails with "Permission denied"
- Can't create symlinks
- Can't write to directories

**Solutions:**

1. **Check write permissions:**
   ```bash
   ls -ld ~
   ls -ld ~/.config
   ```
   - Should have write permissions for your user

2. **Remove conflicting files:**
   - If symlink destinations already exist:
   ```bash
   rm ~/.vimrc
   rm -rf ~/.config/nvim
   # etc. for other conflicting files
   ```

3. **Ensure script is executable:**
   ```bash
   chmod +x setup.sh
   ```

4. **Check for protected directories:**
   - Some directories might be protected by macOS (e.g., Desktop, Documents)
   - Grant Terminal/iTerm2 full disk access in System Preferences

---

## Neovim Startup Errors

**Symptoms:**
- Errors on Neovim startup
- Plugins fail to load
- Lua errors in `:messages`

**Solutions:**

1. **Check Neovim version:**
   ```bash
   nvim --version
   ```
   - Requires Neovim 0.9.0+ for lazy.nvim

2. **Check for syntax errors:**
   - Look at `:messages` after startup
   - Check `~/.local/state/nvim/` logs

3. **Reset plugin state:**
   ```bash
   rm -rf ~/.local/share/nvim
   rm -rf ~/.local/state/nvim
   rm -rf ~/.cache/nvim
   ```
   - Restart Neovim (fresh install)

4. **Update lazy.nvim:**
   - Run `:Lazy update`
   - Then `:Lazy sync`

---

## Colors Look Wrong in Terminal

**Symptoms:**
- Theme colors don't match expected
- Syntax highlighting looks broken
- Background transparency not working

**Solutions:**

1. **Check terminal color support:**
   ```bash
   echo $TERM
   ```
   - Should be `xterm-256color` or `screen-256color` (for tmux)

2. **For WezTerm:**
   - Verify terminfo compiled: `ls ~/.terminfo/w/wezterm`
   - Re-run setup: `./setup.sh`

3. **For tmux:**
   - Add to `~/.tmux.conf`:
   ```
   set -g default-terminal "screen-256color"
   set -ga terminal-overrides ",*256col*:Tc"
   ```

4. **Check Neovim colorscheme:**
   - Run `:colorscheme` to see current theme
   - Should be `tokyonight`

---

## Slow Zsh Startup

**Symptoms:**
- Shell takes several seconds to start
- Noticeable delay when opening new terminal

**Solutions:**

1. **Check for duplicate sourcing:**
   ```bash
   cat ~/.zshrc | grep "source.*dotfiles"
   ```
   - Should only see ONE source line

2. **Check oh-my-zsh plugins:**
   - Edit `~/.dotfiles/.zshrc`
   - Reduce plugins list if too many enabled

3. **Profile startup time:**
   ```bash
   time zsh -i -c exit
   ```
   - Should be under 0.5s

4. **Disable slow plugins:**
   - Common culprits: `ssh`, `nvm`, heavy themes
   - Use lazy-loading for tools like pyenv, rbenv

---

## Git Delta Not Showing Colors

**Symptoms:**
- `git diff` output looks plain
- No syntax highlighting in diffs

**Solutions:**

1. **Verify git-delta installed:**
   ```bash
   which delta
   ```
   - Install via Homebrew: `brew install git-delta`

2. **Check git configuration:**
   ```bash
   git config --get core.pager
   ```
   - Should show `delta`

3. **Verify themes.gitconfig symlinked:**
   ```bash
   ls -la ~/.themes.gitconfig
   ```

4. **Test delta directly:**
   ```bash
   echo "test" | delta
   ```

---

## Additional Help

If you encounter issues not covered here:

1. **Check logs:**
   - Neovim: `~/.local/state/nvim/`
   - Shell: Run with `set -x` for debug output

2. **Verify symlinks:**
   ```bash
   ls -la ~ | grep dotfiles
   ```

3. **Re-run setup:**
   ```bash
   cd ~/.dotfiles
   ./clean.sh    # Remove all symlinks
   ./setup.sh    # Recreate everything
   ```

4. **Check file permissions:**
   ```bash
   ls -la ~/.dotfiles
   ```
   - All files should be readable/writable by your user
