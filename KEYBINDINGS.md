# Keyboard Shortcuts Reference

Quick reference for all keyboard shortcuts across development tools.

---

## Neovim/Vim

**Leader Keys:**
- Leader: `,`
- Local Leader: `;`

### Buffer Management

| Key | Action |
|-----|--------|
| `,]` | Next buffer |
| `,[` | Previous buffer |
| `,bd` | Delete buffer (preserves layout) |

### Fuzzy Finder (fzf-lua)

| Key | Action |
|-----|--------|
| `<C-p>` | Find files (visual selection pre-fills query) |
| `<C-o>` | Live grep |
| `,ll` | Find files |
| `,lk` | Live grep |
| `,lj` | Grep word under cursor |
| `,lr` | Refresh file cache |

### File Explorer (Neo-tree)

| Key | Action |
|-----|--------|
| `,m` | Toggle file tree (no focus) |
| `,n` | Focus tree & reveal file |
| `,b` | Show tree (no focus) |
| `,g` | Toggle git status view |

### LSP (Language Server Protocol)

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `<F2>` | Rename symbol |
| `<F3>` | Format document |
| `<F4>` | Code actions |
| `gh` | Toggle inlay hints |
| `gL` | Toggle LSP lens |
| `<C-LeftMouse>` | Go to definition (like VS Code) |
| `,rl` | Restart all LSP servers |

### Bottom Drawers

| Key | Action | Color |
|-----|--------|-------|
| `,z` | Toggle Terminal Z | Blue |
| `,x` | Toggle Terminal X | Purple |
| `,t` | Toggle Diagnostics | Red |
| `,s` | Toggle Git Status | Yellow |
| `,b` | Toggle Buffers | Green |
| `,d` | Toggle Document Symbols | Brown |
| `,q` | Close all drawers | - |
| `,Q` | Kill all terminals | - |

### Claude Code

| Key | Action |
|-----|--------|
| `,a` | Toggle Claude Code terminal |

**Note:** Claude Code automatically opens and focuses when launching Neovim to a directory (`nvim .` or `nvim`).

### Git

| Key | Action |
|-----|--------|
| `,gg` | Open Lazygit |
| `,go` | Open current line's blame commit in GitHub |
| `,gf` | Open file in GitHub |
| `,gb` | Git blame |
| `(` | Previous hunk |
| `)` | Next hunk |

### Scratch Buffers

| Key | Action |
|-----|--------|
| `,S` | Open scratch buffer |
| `,Sb` | Select scratch buffer |
| `[[` / `]]` | Prev/next reference |

### Context Menu

| Key | Action |
|-----|--------|
| `<RightMouse>` | Open context menu (LSP, Git, File ops) |

### Diagnostics

| Key | Action |
|-----|--------|
| `gl` | Show diagnostic float |
| `[d` / `]d` | Prev/next diagnostic |

### Scrolling & Navigation

| Key | Action |
|-----|--------|
| `_` | Scroll up (page - 10 lines) |
| `+` | Scroll down (page - 10 lines) |
| `Shift+Arrows` | Move between splits (all modes) |
| `Option+Shift+Arrows` | Move between splits (alternative) |

### Utilities

| Key | Action |
|-----|--------|
| `gx` | Open URL under cursor in browser |
| `<CR>` | Clear search highlight |
| `,fw` | Fix whitespace |
| `,r` | Reload config |
| `,rn` | Rename file (with LSP) |

---

## Tmux

**Prefix:** `Ctrl+A` (not default `Ctrl+B`)

**Configuration:**
- **Vi mode:** Enabled for copy-mode
- **Mouse support:** Full mouse integration with scroll
- **Base index:** Windows start at 1 (not 0)

**Common Commands:**
- `Ctrl+A ?` - Show all keybindings
- `Ctrl+A d` - Detach session
- `Ctrl+A c` - Create window
- `Ctrl+A ,` - Rename window
- `Ctrl+A [` - Enter copy mode (vi-mode enabled)

---

## WezTerm

macOS-friendly keybindings:

| Keybinding | Action |
|------------|--------|
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

---

## Less Pager

Custom keybindings via `.lesskey`:

| Key | Action |
|-----|--------|
| `_` | Page up |
| `+` | Page down |
| `{` | Half page up |
| `}` | Half page down |

---

## Shell Shortcuts

### Git Aliases (50+ in `.zshrc`)

**Common:**
- `co` - checkout
- `br` - branch
- `st` - status
- `dif` - diff with smart options

**Commit:**
- `com` / `cam` - commit / commit -a
- `caam` - amend no-edit
- `chp` - cherry-pick

**Log:**
- `lg` - formatted log
- `lb` - branch log
- `lgm` - my commits

**Push/Pull:**
- `pushme` - push to origin HEAD
- `pullme` - pull from main

**Rebase:**
- `rem` - rebase main
- `rehu` - rebase with --update-refs

**See `.zshrc` for complete list**

### Safety Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `mv` | `mv -i` | Interactive mode (prompts before overwrite) |
| `cp` | `cp -i` | Interactive mode (prompts before overwrite) |
| `rm` | `rm -i` | Interactive mode (prompts before delete) |

### Navigation

| Alias | Action |
|-------|--------|
| `..` | Go up 1 directory |
| `...` | Go up 2 directories |
| `....` | Go up 3 directories |
| `.....` | Go up 4 directories |
| `l` / `ll` / `ls` | Detailed listing with colors (`ls -alFh`) |

### Editor

| Alias | Action |
|-------|--------|
| `v` / `vi` / `n` | Launch neovim |
| `v.` / `n.` | Open neovim in current directory |

### Utilities

| Alias | Action |
|-------|--------|
| `c` | Clear screen |
| `rmswaps` | Remove vim swap files |
| `rebash` | Reload shell config |
| `psg` | Grep processes |
