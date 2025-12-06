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
   - **Architecture changes** - directory restructuring, new patterns
   - **New features** - plugins, tools, integrations
   - **Configuration changes** - settings, options, keybindings
   - **Dependency changes** - new tools, removed tools
   - **Bug fixes** - issues resolved

4. **Update CLAUDE.md:**
   - Add a new dated section under "Recent Discoveries"
   - Group related changes with clear headers
   - Include:
     - What changed
     - Why it changed (if apparent)
     - Key files affected
     - New keybindings or commands
   - Update "Key Files & Directories" if structure changed
   - Update "Tech Stack & Dependencies" if tools changed

5. **Update README.md:**
   - Update user-facing documentation:
     - Prerequisites if dependencies changed
     - Installation steps if setup.sh changed
     - Keybindings table if mappings changed
     - Plugin lists if plugins changed
   - Keep it concise - README is for users, not internal context

6. **Verify updates:**
   - Ensure CLAUDE.md and README.md are consistent
   - Check that key information isn't duplicated unnecessarily
   - Verify formatting is clean

## Output

Provide a summary of:

- Number of commits analyzed
- Major changes documented
- Sections updated in each file
