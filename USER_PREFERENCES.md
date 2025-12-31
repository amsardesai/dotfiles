# Global User Preferences

<!--
  ┌─────────────────────────────────────────────────────────────────────────┐
  │  PERSISTENT MEMORY - User-level preferences for Claude Code            │
  ├─────────────────────────────────────────────────────────────────────────┤
  │  This file is symlinked to ~/.claude/CLAUDE.md and applies to ALL      │
  │  Claude Code sessions on any device using these dotfiles.              │
  │                                                                         │
  │  ⚠️  PUBLIC REPOSITORY WARNING                                          │
  │  This dotfiles repository is PUBLIC. Never add credentials, API keys,  │
  │  tokens, or sensitive information to this file. Use 1Password CLI.     │
  │                                                                         │
  │  Purpose:                                                               │
  │  - Store facts about me that Claude should remember across sessions    │
  │  - Define communication preferences and working styles                 │
  │  - Set project-specific rules (detected by working directory path)     │
  │                                                                         │
  │  Updates:                                                               │
  │  - Use `/remember-about-me <message>` to add new information           │
  │  - Claude will maintain structure and place info in correct section    │
  │                                                                         │
  │  For dotfiles-specific AI context, see AGENTS.md in the repo root.     │
  └─────────────────────────────────────────────────────────────────────────┘
-->

## About Me

My name is Ankit Sardesai.

### Professional

- Software engineer at Notion (productivity app)
- Specializations: web performance, accessibility, DX, design systems
- Primary language: TypeScript

### Tools & Software

- Password manager: 1Password (manages logins, SSH keys, secrets)

## Shell Environment

**Interactive mode aliases (safety):**

My `.zshrc` has these aliases to prevent accidental overwrites/deletions:
- `alias mv="mv -i"`
- `alias cp="cp -i"`
- `alias rm="rm -i"`

**Important for Claude:** When running `rm`, `cp`, or `mv` commands, always use the force flag (`-f`) to avoid confirmation prompts that will cause commands to hang:
- Use `rm -f` instead of `rm`
- Use `cp -f` instead of `cp`
- Use `mv -f` instead of `mv`

## Communication Preferences

I often have trouble understanding walls of text, so when you explain
concepts, use bullet points, good formatting, so it's easy for me to
understand.

Before diving into solutions, do one or two rounds of assumption checks
with me so that we can drive towards a full featured solution more
efficiently.

Prefer cautious development when working with AI - spend more time
verifying assumptions to increase the chance of reaching a working
solution on the first attempt (e.g., verify docker state, API endpoints,
file paths, environment variables before writing code, do web searches).

Use emojis and enthusiastic tone to make coding sessions more engaging
and fun (balanced, not excessive).

When pushing commits, provide clickable links to the repo, branch, and
commit so I can easily follow up in the browser.

## Git & Development Workflow

**Commit practices (all repos):**

- Keep changes atomic - one logical change per commit
- Keep commit messages detailed and descriptive
- Follow the repository's commit message template if one exists
- Provide thorough test plans in commit messages or PR descriptions

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

**Git workflow (Graphite):**

- I work in a stacked PR workflow using Graphite
- Use `gt` (graphite) commands instead of raw git for commits
- Stick to 1 commit per branch - amend existing commits rather than adding new ones
- If my branches have multiple commits, consolidate them to 1 commit per branch
- Changes are stacked and sent to GitHub via Graphite PRs

**Notion monorepo:**

- The Notion Dev MCP server is a goldmine of a reference for what to do in Notion.
- Please use it liberally, alongside web searches, when figuring out tasks.
