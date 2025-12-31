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
