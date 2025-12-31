# Document Recent Changes

Analyze all changes made to this repository since the last documentation update and update CLAUDE.md and README.md accordingly.

## Steps

1. **Find the last documentation update:**
   - Check `git log --format="%h %ad %s" --date=short -- CLAUDE.md README.md` to find when docs were last updated
   - Identify the commit hash to use as the baseline

2. **Analyze changes since then:**
   - Run `git log --oneline <baseline>..HEAD` to see all commits
   - Run `git diff --stat <baseline>..HEAD` to see changed files
   - Read key changed files to understand what was modified and why

3. **Categorize the changes:**
   - **Features** - new plugins, tools, integrations, functionality
   - **Bug Fixes** - issues resolved, regressions fixed
   - **Improvements** - optimizations, refactors, enhancements
   - **Configuration** - settings, options, keybindings changes
   - **Dependencies** - new tools, removed tools, version updates

4. **Update documentation files:**

   **CHANGELOG.md** (for recent discoveries/changes):
   - Add a new dated section at the top
   - Categorize changes as: Features, Bug Fixes, Improvements, Configuration
   - Include what changed, why (if apparent), key files affected
   - Use clear headers for each change
   - This is the primary historical record

   **AGENTS.md** (for architecture/patterns only):
   - Update "Key Files & Directories" if structure changed
   - Update "Tech Stack & Dependencies" if tools changed
   - Update "Architecture & Patterns" if design decisions changed
   - Do NOT add to changelog - that's in CHANGELOG.md now

   **KEYBINDINGS.md** (if keybindings changed):
   - Update relevant sections with new shortcuts
   - Maintain categorical organization (Neovim, Tmux, WezTerm, etc.)
   - Keep table format consistent

   **TROUBLESHOOTING.md** (if new common issues discovered):
   - Add new issue + solution sections
   - Use clear problem/solution format

   **README.md** (user-facing changes only):
   - Update Prerequisites if dependencies changed
   - Update Installation steps if setup.sh changed
   - Keep it concise - detailed info goes in other docs

5. **Verify updates:**
   - Ensure all documentation files are consistent
   - Check that information isn't duplicated unnecessarily
   - Verify formatting is clean and Unicode characters preserved (│ ─ ┌ └ etc.)
   - Cross-check that links between docs are valid

6. **Test the changes:**
   - Verify symlinks still work (`.claude/CLAUDE.md` → `AGENTS.md`)
   - Ensure Claude Code can read all files
   - Check that markdown formatting renders correctly

7. **Commit documentation changes:**
   - Stage documentation files: `git add CHANGELOG.md AGENTS.md README.md KEYBINDINGS.md TROUBLESHOOTING.md`
   - Create a detailed commit summarizing what was documented:
     - List the major changes/features that were documented
     - Mention which sections/files were updated
     - Use format: "docs: Document [changes] from [date range]"
   - Example commit message:
     ```
     docs: Document lazy.nvim migration and keybinding updates from Dec 2024

     Updated CHANGELOG.md:
     - Added 2025-12-07 entry for lazy.nvim migration
     - Documented startup time improvements (200ms → 37ms)

     Updated AGENTS.md:
     - Updated plugin manager info (lazy.nvim instead of vim-plug)
     - Updated directory structure for LazyVim-style organization

     Updated KEYBINDINGS.md:
     - Added new LSP keybindings (,rl for restart)
     - Added zoom fix keybindings
     ```

## Output

Provide a summary of:

- Number of commits analyzed
- Major changes documented
- Files updated (CHANGELOG, AGENTS, README, KEYBINDINGS, TROUBLESHOOTING)
- Sections updated in each file
