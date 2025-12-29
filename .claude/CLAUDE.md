# Global User Preferences

<!--
  ┌─────────────────────────────────────────────────────────────────────────┐
  │  PERSISTENT MEMORY - User-level preferences for Claude Code            │
  ├─────────────────────────────────────────────────────────────────────────┤
  │  This file is symlinked to ~/.claude/CLAUDE.md and applies to ALL      │
  │  Claude Code sessions on any device using these dotfiles.              │
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
  │  For dotfiles-specific AI context, see /CLAUDE.md in the repo root.    │
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
file paths, environment variables before writing code).

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

**Git workflow (Graphite):**
- Use `gt` (graphite) commands instead of raw git for commits
- Stick to 1 commit per branch - amend existing commits rather than adding new ones
- Keep commit messages detailed and descriptive
- Changes are stacked and sent to GitHub via graphite PRs
