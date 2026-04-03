---
name: handoff
description: Package current session context into a handoff memo so a fresh Claude Code session can pick up where this one left off. Writes .claude/handoff.md with decisions, open tasks, key files, and next steps.
argument-hint: ['optional focus or note', 'e.g. "focus on the auth refactor" or "we were debugging the sync bug"']
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

## Instructions

You are the **Session Handoff** skill. Your job is to capture everything a fresh Claude Code session would need to seamlessly continue the current conversation's work — then write it to a structured handoff file.

### Step 1: Analyze Current Session

Review the full conversation above this skill invocation. If `$ARGUMENTS` provides focus, narrow accordingly.

Extract:

**A. Mission** — What is the user trying to accomplish? One sentence.

**B. Decisions Made** — Architectural choices, approaches chosen, approaches rejected and why. Bulleted list.

**C. Key Files** — Files that were read, edited, or are central to the task. Include paths and a brief note on each file's role.

**D. Current State** — Where did work stop? What's done, what's in progress, what's blocked?

**E. Open Tasks** — Remaining work items in priority order. Be specific enough that a fresh session can act on them without re-reading the conversation.

**F. Context & Gotchas** — Non-obvious things the next session needs to know: edge cases discovered, things that don't work, environment quirks, user preferences expressed during the session.

**G. Next Step** — The single most important thing the next session should do first.

### Step 2: Write Handoff File

Write the handoff memo to `.claude/handoff.md`:

```markdown
---
created: [YYYY-MM-DD HH:MM]
from_session: [brief label, e.g. "auth-refactor" or "sync-bug-debug"]
status: pending
---

# Session Handoff

## Mission
[One sentence]

## Decisions
- [Decision 1]
- [Decision 2]

## Key Files
- `path/to/file.py` — [role]
- `path/to/other.js` — [role]

## Current State
[What's done, what's in progress, what's blocked]

## Open Tasks
1. [Most important remaining task]
2. [Next task]
3. [...]

## Gotchas
- [Non-obvious thing 1]
- [Non-obvious thing 2]

## Next Step
[The single first thing to do]
```

### Step 3: Check for Existing Handoff

Before writing, check if `.claude/handoff.md` already exists. If it does:
- Read it
- Ask the user: "There's an existing handoff from [date/label]. Overwrite it, or append as a second section?"
- If no response needed (e.g., it's clearly stale), overwrite with a note about what it replaced

### Step 4: Confirm

After writing, output:

```
Handoff written → .claude/handoff.md
Label: [session label]
Open tasks: [count]
Next step: [the next step]

Start a new session — it will auto-detect the handoff and pick up where we left off.
```

## Design Principles

- **Completeness over brevity** — a fresh session has ZERO context. Include everything it needs. Err on the side of too much detail.
- **Actionable > Narrative** — write tasks as instructions, not history. "Implement the retry logic in sync.py using exponential backoff" not "we discussed adding retries".
- **Preserve the why** — for each decision, include the reasoning. The next session may face the same tradeoff and needs to know why this path was chosen.
- **One file, one place** — always `.claude/handoff.md`. No fragmentation.
