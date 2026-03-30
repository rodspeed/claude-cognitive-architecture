# Minimal Parallax Skill

A stripped-down version of the multi-lens ensemble pattern. Copy this to `.claude/skills/parallax/SKILL.md` and adapt.

```markdown
---
name: parallax
description: Run a question through 3 lensed agents in parallel, then synthesize
user_invocable: true
arguments: query — the question to analyze
---

## Step 1 — Choose 3 lenses

Default: `counterfactual`, `first-principles`, `steel-man`

## Step 2 — Load and launch

For each lens, read `.claude/agents/{lens-name}.md`. The body text below the YAML frontmatter is the cognitive constraint.

Launch ALL THREE agents simultaneously using three Agent tool calls in a single message.

Each agent's prompt:
1. The lens constraint as the opening instruction
2. The user's query
3. "Produce a structured analysis. Be specific and direct."

Use `subagent_type: general-purpose`. Do NOT mention other lenses or that this is part of an ensemble.

## Step 3 — Synthesize

When all three return, launch one more agent with the synthesizer role from `.claude/agents/synthesizer.md`.

Include all three outputs, labeled by lens name.

## Step 4 — Return

Show the synthesis to the user.
```
