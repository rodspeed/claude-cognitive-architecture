---
name: research
description: Parallel deep research — decomposes a question into facets, spawns researcher agents simultaneously, synthesizes findings. Composable with lenses.
user_invocable: true
arguments: question — the research question; optional flags: --facets "a,b,c" — override auto-decomposition, --lens [lens name] — apply cognitive constraint to all researchers, --verbose — show individual researcher outputs, -f [file path] — include file as context
allowed-tools: Read, Glob, Grep, Agent, WebSearch, WebFetch
---

# Research — Parallel Deep Investigation

You are orchestrating a multi-agent research ensemble. Researcher agents investigate facets of a question in parallel, then a synthesizer integrates their findings.

## Step 1 — Parse Arguments

Parse `$ARGUMENTS` for:
- The research question (required — everything that isn't a flag)
- `--facets "a,b,c"` — explicit facet list (comma-separated, quoted)
- `--lens NAME` or `-l NAME` — apply a cognitive lens to all researchers
- `--verbose` or `-v` — show individual researcher outputs before synthesis
- `-f PATH` — read a file and include its contents as context for all researchers

If `-f` is specified, read the file with the Read tool.

If no question is provided, ask what to research.

## Step 2 — Decompose into Facets

If `--facets` is provided, use those directly. One researcher per facet.

If not, decompose the question yourself. Think about:
- What are the distinct sub-questions that together cover the full research question?
- Are there sub-questions that would benefit from independent investigation (different source domains, different methods)?
- Would any facet naturally surface different evidence than the others?

**No fixed count.** Use as many facets as the question needs — could be 2, could be 5. Cap at 5 to keep synthesis coherent. Simple questions get fewer facets. Complex questions get more. Don't pad.

State the facets to the user before launching agents:

```
Decomposed into {n} facets:
1. [facet description]
2. [facet description]
...
```

## Step 3 — Load Agent Definitions

**Load the researcher role:** Read `.claude/agents/researcher.md`. The body text (below YAML frontmatter) is the researcher protocol.

**If `--lens` is specified:** Read `.claude/agents/{lens-name}.md`. If the file doesn't exist, tell the user and abort. The body text is the cognitive constraint.

**If `--lens` is NOT specified:** Read `.claude/agents/regularizer.md`. Apply this lightweight constraint to all researchers by default. The filler-word ban improves reasoning accuracy with no compliance cost. It is only useful on unlensed agents — lenses already disrupt default generation, making the regularizer redundant when stacked. If a lens is active, do NOT also prepend the regularizer.

**Load the synthesizer:** Read `.claude/agents/synthesizer.md` (needed for Step 5).

## Step 4 — Launch Researchers in Parallel

Launch ALL researcher agents simultaneously in a **single message** using one Agent tool call per facet.

Each agent's prompt must include, in this order:
1. The cognitive lens constraint (if `--lens` was specified) OR the regularizer constraint (if no lens). Never both.
2. The researcher role protocol (from the agent file)
3. Any file context (if `-f` was used)
4. The specific facet assignment: "Your research facet: [facet description]. This is one part of a broader question: [original question]. Stay focused on your facet."

Use `subagent_type: general-purpose`. Each agent prompt must be self-contained. Do NOT mention other facets or that this is part of an ensemble.

**Critical: all researcher agents must be launched in a single message for parallel execution.**

## Step 5 — Synthesize

When all researchers return, construct a synthesis.

If `--verbose` was specified, first show each researcher's output under its facet name.

Launch ONE MORE agent with a synthesis prompt. Use the **Standard Mode** instructions from the synthesizer agent file, but adapt the framing:

> You received research findings from {n} independent researchers, each investigating a different facet of the same broad question. They worked in parallel and did not see each other's findings.
>
> **Original question:** [the user's research question]
>
> **Facets investigated:**
> 1. [facet] — Researcher 1
> 2. [facet] — Researcher 2
> ...
>
> Produce a synthesis with these sections:
>
> **COVERAGE MAP**: Which facets produced strong findings? Which came back thin? Where are the remaining gaps?
>
> **BLIND SPOTS**: Findings that appeared in only one researcher's output — things a single-threaded investigation would likely miss. Name the researcher and quote the finding.
>
> **DIVERGENCE**: Points where researchers' findings conflict or frame the same evidence differently.
>
> **CONSENSUS**: Where researchers independently corroborate each other. Brief.
>
> **INTEGRATED ANSWER**: Drawing on all findings, what is the best current answer to the original question? Flag confidence level (high/medium/low) for each major claim. Note what remains unknown.
>
> Rules: Coverage map first. Preserve provenance — if a researcher cited a source, keep the citation. Do not add findings of your own. Be concise.

Include all researcher outputs in the prompt, labeled by facet.

## Step 6 — Return

Show the synthesis agent's output. At the end, add a footer:

```
---
research | {n} facets{lens_info}
```

Where `{lens_info}` is ` | lens: {name}` if a lens was applied, or empty string if not.

Do NOT show raw researcher outputs unless `--verbose` was specified.
