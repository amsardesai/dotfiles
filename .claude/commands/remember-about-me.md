---
name: remember-about-me
description: Add new information to my persistent user preferences
argument-hint: <message>
---

# Remember About Me

The user wants you to remember the following information about them:

> $ARGUMENTS

## Your Task

1. **Read** the current user preferences file at `~/.claude/CLAUDE.md` (or `~/.dotfiles/USER_PREFERENCES.md` if in the dotfiles repo)

2. **Analyze** the message and determine which section it belongs to:
   - **About Me → Professional** - work, skills, job, technical expertise
   - **About Me → Personal Background** - location, family, origins, life plans
   - **About Me → Products I Own** - physical items, equipment, devices
   - **Communication Preferences** - how the user likes to receive information
   - **Project-specific rules** - workflows for specific codebases (detected by path)
   - **New section** - if it doesn't fit existing categories, propose a new one

3. **Update** the file by:
   - Adding the new information as a concise bullet point
   - Placing it in the correct section
   - Maintaining consistent formatting (bullet points, no prose)
   - Avoiding duplicates (update existing info if it's a correction)
   - Preserving the existing structure and all other content

4. **Confirm** what you added and where

## Guidelines

- Keep entries concise (single bullet point when possible)
- Use consistent formatting with existing entries
- If the info updates/corrects existing info, replace rather than duplicate
- If unsure which section, ask the user
- Never remove existing information unless explicitly asked
