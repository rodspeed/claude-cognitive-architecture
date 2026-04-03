---
name: parallax
description: "Multi-lens analysis — runs a query through 3 cognitively diverse agents in parallel, then synthesizes blind spots, divergences, and consensus. Use when you want to triangulate a question, review code from multiple angles, or stress-test a decision."
user_invocable: true
arguments: "query — the question, review request, or decision to analyze; optional flags: --profile [debug|code-review|architecture|decision|writing], --lenses [comma-separated lens names], --diverge — decision mode, --verbose — show individual lens outputs, -f [file path]"
---

# Parallax — Multi-Lens Analysis

You are deploying a 3-agent reasoning ensemble with a synthesizer. Each agent reasons under a different cognitive constraint. They do not see each other's work. The synthesizer identifies blind spots, divergences, and consensus.

## Lens Definitions

Lenses are defined as standalone agent files in `.claude/agents/`. Each file contains YAML frontmatter and a body with the cognitive constraint text.

Available lenses: `counterfactual`, `analogical`, `minimal`, `no-possession`, `evidential`, `first-principles`, `process-only`, `steel-man`, `eprime`, `regularizer`

To add a new lens, create a file at `.claude/agents/{lens-name}.md` with `type: lens` in the frontmatter. No edits to this skill needed.

## Profiles

| Profile | Lenses | Use when |
|---------|--------|----------|
| debug | counterfactual, analogical, minimal | Finding bugs, root cause analysis |
| code-review | counterfactual, minimal, evidential | Reviewing diffs and PRs |
| architecture | first-principles, process-only, steel-man | Design decisions |
| decision | counterfactual, first-principles, steel-man | Choices under uncertainty |
| writing | no-possession, evidential, minimal | Improving prose |
| regularize | regularizer, counterfactual, first-principles | Accuracy-optimized analysis — leads with the empirically strongest constraint |

Default profile: **debug**

## Step 1 — Parse Arguments

Parse `$ARGUMENTS` for:
- The query text (required — everything that isn't a flag)
- `--profile NAME` or `-p NAME` — select a profile (default: debug)
- `--lenses a,b,c` or `-l a,b,c` — override profile with specific lenses
- `--diverge` — use diverge synthesis mode (for decisions)
- `--verbose` or `-v` — show individual lens outputs before synthesis
- `-f PATH` — read a file and include its contents as context

If `-f` is specified, read the file with the Read tool. Prepend its contents to the query as context.

If the user provides no query, ask what they want to analyze.

## Step 2 — Launch 3 Agents in Parallel

Determine the 3 lenses from the profile or `--lenses` flag.

**Load lens definitions:** For each lens, read `.claude/agents/{lens-name}.md`. The body text (everything below the YAML frontmatter `---`) is the cognitive constraint. If a lens file doesn't exist, tell the user and abort.

Launch ALL THREE agents simultaneously in a **single message** using three Agent tool calls.

Each agent's prompt must include:
1. The lens constraint (body text from the agent file) as the opening instruction
2. Any file context (if `-f` was used)
3. The user's query

Use `subagent_type: general-purpose`. Each agent prompt should be self-contained — the constraint, the context, and the query. Do NOT include any mention of other lenses or that this is part of an ensemble.

**Critical: all three agents must be launched in a single message for parallel execution.**

## Step 3 — Synthesize

When all three agents return, construct a synthesis. If `--verbose` was specified, first show each lens output under its name.

Then launch ONE MORE agent with a synthesis prompt.

**Load the synthesizer:** Read `.claude/agents/synthesizer.md`. Use the **Standard Mode** section for default, or the **Diverge Mode** section if `--diverge` was specified.

Construct the synthesis prompt by combining:
1. The appropriate mode's instructions from the synthesizer agent file
2. All three agent outputs, labeled by lens name

## Step 4 — Return

Show the synthesis agent's output to the user. At the end, add a brief footer:

```
---
parallax | {lens1}, {lens2}, {lens3}
```

Do NOT show the raw agent outputs unless `--verbose` was specified. Keep it clean.
