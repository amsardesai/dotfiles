# Global User Preferences

> **PERSISTENT MEMORY** - User-level preferences for Claude Code
>
> **Scope:** This file is symlinked to `~/.claude/CLAUDE.md` and applies to ALL Claude Code sessions on any device using these dotfiles.
>
> **⚠️ PUBLIC REPOSITORY**
> Never add credentials, API keys, tokens, or sensitive information. Use 1Password CLI.
>
> **Updates:** Use `/remember-about-me <message>` to add new information. Claude will maintain structure and place info in correct section.
>
> **For dotfiles-specific AI context, see [AGENTS.md](AGENTS.md) in the repo root.**

---

## Quick Reference

| Category             | Key Info                                                                  |
| -------------------- | ------------------------------------------------------------------------- |
| **Name**             | Ankit Sardesai                                                            |
| **Role**             | Software Engineer at Notion                                               |
| **Focus**            | Web performance, accessibility, DX, design systems                        |
| **Primary Language** | TypeScript                                                                |
| **Password Manager** | 1Password (logins, SSH keys, secrets)                                     |
| **Shell**            | Zsh with interactive mode aliases (`-i` flags on mv/cp/rm)                |
| **Git Workflow**     | Atomic commits, detailed messages, Graphite (stacked PRs) for Notion repo |

---

## About Me

### Professional

- Software engineer at Notion (productivity app)
- Specializations: web performance, accessibility, developer experience, design systems
- Primary language: TypeScript

### Tools & Software

- Password manager: 1Password (manages logins, SSH keys, secrets)

---

## Shell Environment

**Interactive mode aliases (safety):**

My `.zshrc` has these aliases to prevent accidental overwrites/deletions:

- `alias mv="mv -i"`
- `alias cp="cp -i"`
- `alias rm="rm -i"`

**⚠️ Important for Claude:** When running `rm`, `cp`, or `mv` commands, **always use the force flag (`-f`)** to avoid confirmation prompts that will cause commands to hang:

- Use `rm -f` instead of `rm`
- Use `cp -f` instead of `cp`
- Use `mv -f` instead of `mv`

---

## Communication Preferences

**Formatting:**

- Use bullet points, good formatting, clear structure (I have trouble with walls of text)
- Make explanations scannable and easy to understand

**File references:**

- Always render file paths with line numbers: `src/utils.ts:42`
- Include column numbers when referring to specific positions: `src/utils.ts:42:8`
- This enables WezTerm hyperlink detection for CMD+Click navigation to Neovim

**Development approach:**

- **Assumption checks:** Do 1-2 rounds of assumption verification before diving into solutions
- **Cautious development:** Verify assumptions first (docker state, API endpoints, file paths, environment variables) before writing code
- **Web searches:** Use web searches when uncertain about APIs, configuration, or implementation details

**Task Execution:**

- When making multiple file changes, edits, or searches that don't depend on each other, prefer executing them in parallel (single message, multiple tool calls)
- When debugging, run independent diagnostic commands in parallel (e.g., checking logs, inspecting state, testing hypotheses)
- Only serialize when there's a real dependency or when sequential execution aids debugging

**Tone:**

- Use emojis and enthusiastic tone to make coding sessions engaging and fun (balanced, not excessive)
- When pushing commits, provide clickable links to repo, branch, and commit

---

## Git & Development Workflow

**Commit practices (all repos):**

- Keep changes **atomic** - one logical change per commit
- Use **Conventional Commits** format for all commit messages

**Creating commits:**

1. Gather context by running these commands:
   - `git status --short` - changed files
   - `git diff` - full diff
   - `git log --oneline -5` - recent commits for style reference

2. Determine the **type** and **scope** (for Conventional Commits):
   - **Type** (required, MUST be one of these exact values):
     `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
   - **Scope** (in parentheses, one word) - this is where component names, areas, and categories go:
     - Component name (e.g., `Button`, `Modal`, `Sidebar`)
     - Product area (e.g., `onboarding`, `billing`, `search`)
     - Category (e.g., `a11y`, `i18n`, `deps`)
   - ⚠️ **Common mistake:** `a11y`, `perf`, `i18n` are **scopes**, not types. Use `feat(a11y)` or `fix(a11y)`, never `a11y(component)`

3. Generate commit message using **Conventional Commits** format:
   - **Title:** `type(scope): description` (lowercase type, no period at end)
   - **Description:** Clear, concise explanation of **why** the change is being made (not just what changed)
   - **Reviewer notes:** Important context reviewers should know (only if not already covered by description)
   - **Test plan:** Only include if confident in testing approach; omit rather than show low-confidence plans
   - Add at the end:

     ```
     👨🏽‍💻 Generated with a coding agent

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

4. Create the commit using `git commit` (or `gt create` in notion-next)

**PR descriptions:**

- Keep descriptions **concise and casual**
- Focus on the **"why"** behind the change
- If the "why" isn't obvious from the code, ask me before writing the description
- **Include links to Notion docs** when relevant (task links, important context docs)

---

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

> ⚠️ **CRITICAL: ALWAYS USE GRAPHITE (`gt`) COMMANDS**
>
> **NEVER use raw git commands** for commits, pushes, syncing, or rebasing.
> Using raw git WILL break the stacked PR workflow. This is non-negotiable.

**Prohibited git commands → Use Graphite instead:**

| ❌ NEVER Use              | ✅ Use Instead              | Purpose                |
| ------------------------- | --------------------------- | ---------------------- |
| `git commit`              | `gt create -a -m "msg"`     | New branch + commit    |
| `git commit --amend`      | `gt modify -a`              | Amend current commit   |
| `git push`                | `gt submit --draft`         | Push to remote (draft) |
| `git pull`                | `gt sync`                   | Sync with trunk        |
| `git fetch && git rebase` | `gt sync` then `gt restack` | Update and restack     |
| `git rebase`              | `gt restack`                | Rebase stack on trunk  |
| `git checkout -b`         | `gt create`                 | Create new branch      |
| `git merge`               | Never (Graphite handles)    | Merge branches         |

**One commit per branch (strictly enforced):**

- ALWAYS amend with `gt modify -a`, NEVER add new commits
- Before committing, check `gt log` - if branch has commits, amend don't add
- If a branch has multiple commits, consolidate them before proceeding

**Safe read-only git commands (OK to use):**

- `git status`, `git diff`, `git log`, `git branch`, `git show`, `git blame`, `git stash`

**GitHub CLI (`gh`) commands:**

| ❌ NEVER Use   | ✅ Use Instead | Why                      |
| -------------- | -------------- | ------------------------ |
| `gh pr create` | `gt submit`    | Graphite creates PRs     |
| `gh pr merge`  | Never          | Graphite handles merging |

OK to use `gh` for read/info operations:

- `gh pr view`, `gh pr checks`, `gh pr comment`, `gh pr list`
- `gh api`, `gh issue`, `gh repo view`

**Creating commits (notion-next specific):**

Follow the global "Creating commits" workflow above, with these additions:

1. Read the PR template: `cat .github/pull_request_template.md`
2. **Structure the commit message to match the PR template exactly** - tooling validates this format
3. Check at least one `[x]` box in each checkbox section (testing and feature gate)
4. Use `gt create -a -m "FULL_COMMIT_MESSAGE"` (not `git commit`)
5. Run `gt submit --draft` to push as a draft PR

**Submitting PRs:**

- **ALWAYS use `--draft`** when running `gt submit` (i.e., `gt submit --draft`)
- **NEVER use `--publish`** unless explicitly requested by the user
