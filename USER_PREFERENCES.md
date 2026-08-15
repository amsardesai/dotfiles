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

**Branch naming:**

- **Prefix:** Always start branch names with `amsardesai--` (e.g., `amsardesai--fix-popup-render-prop`)
- **Max length:** Keep branch names under 60 characters total (including prefix)
- **Format:** Use kebab-case after the prefix: `amsardesai--short-description-here`
- **Be concise:** Describe the change in 3-6 words, not the full commit message
- ⚠️ **NEVER** include commit descriptions, test plans, or full sentences in branch names
- **Good examples:**
  - `amsardesai--fix-popup-render-prop`
  - `amsardesai--migrate-modal-content-api`
  - `amsardesai--update-sidebar-a11y`
- **Bad examples:**
  - `amsardesai--refactor_defaultpopupormodal_rename_render_prop_to_content_description_part_b1.5...` (way too long, includes description)

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
   - ⚠️ **Scope specificity:** Always use the most specific scope possible. Prefer component names (e.g., `Button`, `Tooltip`) over generic library names (e.g., `nds`). Only use broad scopes when changes truly affect overall architecture across multiple components.
   - ⚠️ **Common mistake:** `a11y`, `perf`, `i18n` are **scopes**, not types. Use `feat(a11y)` or `fix(a11y)`, never `a11y(component)`

3. Generate commit message using **Conventional Commits** format:
   - **Title:** `type(scope): description` (lowercase type, no period at end)
   - **Description:** Clear, concise explanation of **why** the change is being made (not just what changed)
   - **Reviewer notes:** Important context reviewers should know (only if not already covered by description)
   - **Test plan:** Only include if confident in testing approach; omit rather than show low-confidence plans
   - ⚠️ **MANDATORY — NEVER OMIT:** Every commit message MUST end with the following attribution block. This is non-negotiable:

     ```
     👨🏽‍💻 Generated by coding agent

     Co-Authored-By: <YOUR_ATTRIBUTION>
     ```

     **Commit message attribution format:**
     - Use: `Co-Authored-By: <Harness Name> (<Exact Model Name>) <noreply@...>`
     - Always include both the harness name and the exact model name when the harness exposes it
     - Do not collapse attribution to just the harness name like `Codex <...>` or `Cursor <...>`
     - Examples:
       - `Claude Code (Claude Opus 4.6) <noreply@anthropic.com>`
       - `Codex (GPT-5.4) <noreply@openai.com>`
       - `Cursor (Claude Sonnet 4.6) <noreply@cursor.com>`
       - `OpenCode (GPT-5.4) <noreply@opencode.ai>`
     - When using OpenCode specifically, attribute commits and PRs to `OpenCode (GPT-5.4) <noreply@opencode.ai>`, not the model vendor domain

4. Create the commit using `git commit` (or `gt create` in notion-next)

**PR title practices (all repos):**

- PR titles MUST use Conventional Commits format like commits: `type(scope): description`
- This applies even if repo-local tools, skills, or templates suggest bracketed prefixes like `[Project] fix: ...`
- Good: `fix(storybook): keep main homepage manifest complete`
- Bad: `[Storybook] fix: keep main homepage manifest complete`

**PR descriptions:**

- Keep descriptions **concise and casual**
- Focus on the **"why"** behind the change
- If the "why" isn't obvious from the code, ask me before writing the description
- **Include links to Notion docs** when relevant (task links, important context docs)
- **Always include a "Reviewer notes" section** — tell reviewers what they should know and what to look out for (edge cases, areas of concern, things you're unsure about, areas that need extra scrutiny)
- **Auto-update on PR changes:** When pushing new changes to an existing PR, ALWAYS update the PR description to reflect the latest state. Use `gh pr edit --body` (or Graphite equivalent in notion-next) to keep the description in sync.
- ⚠️ **MANDATORY — NEVER OMIT:** Every PR description MUST end with the following attribution block:

  ```
  👨🏽‍💻 Generated by coding agent

  Co-Authored-By: <YOUR_ATTRIBUTION>
  ```

### PR Delivery Workflow

1. Run fast, targeted checks to catch obvious breakage.
2. Submit the PR promptly—do not wait for exhaustive testing. New PRs should be drafts unless instructed otherwise.
3. Share the PR and deploy-preview URLs as soon as they are available.
4. After submission, complete thorough local testing and fix, amend, and resubmit as needed.
5. Keep the PR description, test plan, and evidence current. Do not claim completion while testing or known issues remain.

### UI Evidence

Every UI-related PR MUST include a video recorded with Playwright MCP, Chrome DevTools MCP, or equivalent browser automation.

- Demonstrate the affected user flow and interactions.
- When applicable, include clearly labeled **Before** and **After** videos or screenshots captured under comparable conditions.
- Add evidence directly to the PR description, preferably using the deploy preview for the after state.
- If required evidence cannot be produced, report the blocker instead of omitting it.

**PR comments:**

- Avoid posting PR comments on my behalf unless I explicitly ask, or unless the comment is genuinely necessary to complete the task.
- Prefer summarizing findings to me in chat over posting them on GitHub when a PR comment is optional.
- ⚠️ **MANDATORY — NEVER OMIT:** Every PR comment (review comments, inline comments, general comments) MUST start with the following disclosure as the very first line, before any other content. Replace `<agent>` with the active harness name (for example, Claude, Codex, OpenCode, or Cursor):

  ```
  > 🤖 ⚠️ Warning: this message was posted by <agent> on Ankit's behalf! ⚠️ 🤖
  ```

---

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

> ⚠️ **CRITICAL: ALWAYS USE GRAPHITE (`gt`) COMMANDS**
>
> **NEVER use raw git commands** for commits, pushes, syncing, or rebasing.
> Using raw git WILL break the stacked PR workflow. This is non-negotiable.

**Prohibited git commands → Use Graphite instead:**

| ❌ NEVER Use              | ✅ Use Instead              | Purpose                      |
| ------------------------- | --------------------------- | ---------------------------- |
| `git commit`              | `gt create -a -m "msg"`     | New branch + commit          |
| `git commit --amend`      | `gt modify -a`              | Amend current commit         |
| `git push`                | `gt submit`                 | Push/update PRs via Graphite |
| `git pull`                | `gt sync`                   | Sync with trunk              |
| `git fetch && git rebase` | `gt sync` then `gt restack` | Update and restack           |
| `git rebase`              | `gt restack`                | Rebase stack on trunk        |
| `git checkout -b`         | `gt create`                 | Create new branch            |
| `git merge`               | Never (Graphite handles)    | Merge branches               |

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
5. If creating brand-new PR(s), run `gt submit --draft` so the new PRs start as drafts
6. If updating an existing PR, preserve its current draft/published state; do **not** pass `--draft` or `--publish`

**Submitting PRs:**

- **Brand-new PRs:** Use `gt submit --draft` so newly-created PRs start as drafts.
- **Existing PRs:** Preserve the current PR state. Never turn a published PR back into draft. When updating an existing PR, use `gt submit --update-only` if no new PRs should be created, or `gt submit` without `--draft`/`--publish` after verifying Graphite will preserve existing PR state.
- **NEVER use `--publish`** unless explicitly requested by the user
- **Mixed stacks:** If a stack contains both brand-new branches and existing published PRs, first verify which branches already have PRs. Do not use `--draft` on a command that could affect an already-published PR; ask me if Graphite cannot create only the new PRs as draft while preserving existing PR states.

**Reordering stacked PRs:**

- ⚠️ **NEVER close a PR and open a new one** to reorder a stack — actually reorder the branches using Graphite commands (`gt upstack onto`, `gt move`, etc.)
- Closing and reopening PRs for the same changes loses review comments, approvals, and CI history
- Use Graphite's native stack manipulation to move branches to the correct position in the stack
