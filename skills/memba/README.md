# Memba — Quick-Save Memory Skill

## What It Does

Memba is a low-friction memory skill. The user says "memba this" followed by something they want remembered across conversations. Memba classifies it, routes it to the right file, and writes it — fast, with zero ceremony.

## Core Steps

1. **Classify** the input by type (user profile, feedback/preferences, project status, reference material)
2. **Check for duplicates** — read the target file and scan for existing content covering the same ground
3. **Write** — update an existing file (preferred) or create a new one. Weave content into the right section rather than appending to the bottom
4. **Confirm** — tell the user where it was saved and surface 2-3 related memories from across the system (serendipity)

## How to Implement

### Memory Directory Structure

```
memory/
├── MEMORY.md          # Top-level index
├── user/
│   ├── INDEX.md
│   ├── identity.md
│   └── drives.md
├── feedback/
│   ├── INDEX.md
│   └── all.md
├── projects/
│   ├── INDEX.md
│   └── [per-project].md
└── reference/
    ├── INDEX.md
    └── [per-resource].md
```

### Classification Table

| Type | Signal | Route to |
|------|--------|----------|
| **feedback** | Preferences, corrections, "do/don't do X" | `feedback/all.md` |
| **user** | Personal facts, background, identity, interests | `user/` — pick the right file |
| **project** | Status updates, decisions, blockers, goals | `projects/[project].md` |
| **reference** | URLs, dashboards, tools, where-to-find-X | `reference/[resource].md` |

### Related Memory Surfacing

After saving, scan all memory files for content that connects to what was saved. Prioritize surprising connections over obvious ones — the user knows they saved a project update; they may not realize it connects to a feedback rule.

### Design Principles

- **Speed over ceremony** — the user said "memba this", not "let's discuss where this should go"
- **Update > Create** — almost everything fits in an existing file
- **Classify confidently** — don't ask the user which type. Make the call.
- **Dedup is sacred** — never write something that's already there
- **Weave, don't append** — new content lands in the right section, not piled at the bottom
- **Minimal index churn** — only touch INDEX files when creating new memory files
