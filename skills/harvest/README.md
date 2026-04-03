# Harvest — Conversation Knowledge Extractor

## What It Does

Harvest runs at the end of every substantive conversation. It extracts valuable insights — decisions, facts, concepts, connections — and proposes them as new or updated entries in your knowledge system.

The pattern: scan the conversation, deduplicate against existing knowledge, propose additions in a compact table, write approved entries with cross-links.

## Core Steps

1. **Load existing knowledge index** — scan all existing notes/entries for titles, tags, and cross-references to build a dedup index
2. **Analyze the conversation** — extract new knowledge (decisions, facts learned, mental models articulated) and updates to existing entries
3. **Semantic link discovery** — for each proposed entry, find related existing entries beyond obvious title matches (topic overlap, shared tags, graph neighbors)
4. **Propose in compact format** — numbered table with type (NEW/UPDATE/LINK), title, tags, forward links, back-links
5. **Write approved entries** — with standard frontmatter, registered on hub/index pages, with bidirectional cross-links woven into existing entries
6. **Run observe protocol** — as the final step, automatically run the `/observe` skill to collect behavioral evidence from the session

## How to Implement

### Knowledge Store

Harvest needs a place to write. Options:
- A `notes/` directory with markdown files (what the original uses)
- A database or JSON store
- Any system that supports titles, tags, and cross-references

### Dedup Index

Before proposing anything, harvest must know what already exists. Build an in-memory index of:
- All entry titles (for exact dedup)
- All tags (for vocabulary consistency)
- All cross-references (for finding where new entries belong)

### Proposal Format

```
| # | Type | Title | Tags | Links to | Back-links |
|---|------|-------|------|----------|------------|
| 1 | NEW  | [title] | tag1, tag2 | [[Entry A]], [[Entry B]] | A <- this |
| 2 | UPDATE | [existing] +add section | tag1 | +[[Entry C]] | C <- this |
```

### Design Principles

- **Speed over ceremony** — the user should spend <10 seconds reviewing proposals
- **Dedup is sacred** — never create an entry that duplicates existing content
- **Update > Create** — if information fits in an existing entry, update it
- **Graph density** — every entry gets 2-4 cross-references minimum. Orphan entries are waste.
- **Bidirectional by default** — if A links to B, B should link back to A
- **Match siblings** — before writing, check how similar entries look in the system

### Integration with Observe

Harvest's final step runs `/observe` automatically. The two skills form a single atomic operation: harvest captures *what happened*, observe captures *what it reveals about the user*. See `skills/observe/SKILL.md` for the full observe protocol.

### Customization Points

- **What to harvest:** Adjust the extraction criteria for your domain. The default skips trivial exchanges, debugging steps, and code changes (those belong in git).
- **Proposal count:** 2-5 items per harvest. Quality over quantity.
- **Auto-approve:** If you trust the system, skip the proposal step and write directly.
- **Reasoning nudge:** Optionally track how many new entries have been added since the last analysis pass, and suggest running a reasoning/connection-finding tool when the count crosses a threshold.
