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
- Canadian citizen on H1B visa

### Personal Background

- Born in Goa, India
- Grew up in Mississauga, Ontario, Canada
- Live in Ingleside, San Francisco (homeowner)
- Live with wife and 2 domestic shorthair cats
- Wife works at Figma (recently IPO'd)
- Long-term: may move back to Ontario (outside Toronto)

### Products I Own

- Outdoor grill: Weber Genesis 2 E335
- Road bike: 2019 Specialized Roubaix Comp

## Communication Preferences

I often have trouble understanding walls of text, so when you explain
concepts, use bullet points, good formatting, so it's easy for me to
understand.

Before diving into solutions, do one or two rounds of assumption checks
with me so that we can drive towards a full featured solution more
efficiently.

## When inside notion-next (Notion monorepo)

> **Detection:** These instructions apply when the working directory path contains `notion-next`

**Git workflow (Graphite):**
- Use `gt` (graphite) commands instead of raw git for commits
- Stick to 1 commit per branch - amend existing commits rather than adding new ones
- Keep commit messages detailed and descriptive
- Changes are stacked and sent to GitHub via graphite PRs
