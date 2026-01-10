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

| Category | Key Info |
|----------|----------|
| **Name** | Ankit Sardesai |
| **Role** | Software Engineer at Notion |
| **Focus** | Web performance, accessibility, DX, design systems |
| **Primary Language** | TypeScript |
| **Password Manager** | 1Password (logins, SSH keys, secrets) |
| **Shell** | Zsh with interactive mode aliases (`-i` flags on mv/cp/rm) |
| **Git Workflow** | Atomic commits, detailed messages, Graphite (stacked PRs) for Notion repo |

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
- Keep commit messages **detailed and descriptive**
- Follow the repository's commit message template if one exists
- Provide thorough **test plans** in commit messages or PR descriptions

---

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

**Git workflow (Graphite):**

- I work in a **stacked PR workflow** using Graphite
- Use `gt` (graphite) commands instead of raw git for commits
- Stick to **1 commit per branch** - amend existing commits rather than adding new ones
- If my branches have multiple commits, consolidate them to 1 commit per branch
- Changes are stacked and sent to GitHub via Graphite PRs

**Notion monorepo context:**

- The **Notion Dev MCP server** is a goldmine of reference for what to do in Notion
- Use it liberally, alongside web searches, when figuring out tasks

**Creating commits (when user says "create commit", "commit this", etc.):**

1. First, gather context by running these commands:
   - `git branch --show-current` - current branch
   - `git status --short` - changed files
   - `git diff --stat` - diff summary
   - `git diff` - full diff
   - `cat .github/pull_request_template.md` - PR template

2. Analyze the diff and determine the **Area** (one word):
   - Component name (e.g., `Button`, `Modal`, `Sidebar`)
   - Product area (e.g., `onboarding`, `billing`, `search`)
   - Category (e.g., `a11y`, `perf`, `refactor`, `fix`, `feat`)

3. Generate commit message following the **exact** structure from the PR template (read in step 1):
   - Start with `Area: specific change description` as the title
   - Fill in each section from the template
   - Add at the end:
     ```
     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
     ```

4. Run: `gt create -a -m "FULL_COMMIT_MESSAGE"`

**Commit rules:**
- Check at least one `[x]` box in each checkbox section (testing and feature gate)
- 1 commit per branch (amend if needed with `gt modify -a --amend`)
- Be specific - explain WHAT changed and WHY
- Infer testing approach from the changes made
