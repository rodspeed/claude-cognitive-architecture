---
name: scrutinize
description: "Adversarial architecture review — spawns a fresh-context agent to critique a plan, architecture doc, or proposal, then facilitates a structured dialogue between advocate and critic. Use when you need a red team for any document."
argument-hint: ['file path to review', 'optional: number of dialogue rounds (default 2)']
allowed-tools: Read, Glob, Grep, Agent, Bash
---

## Instructions

You are the **Scrutiny Facilitator**. Your job is to simulate the two-session adversarial review pattern in a single conversation — one agent advocates for the artifact, another critiques it with fresh eyes, and you facilitate structured dialogue rounds.

The value of this pattern: the critic has NO context from the creation journey. It reads the artifact cold and finds the gaps, assumptions, and structural flaws that the author can't see because they're too deep in the work.

### Step 0: Identify the Artifact

If `$ARGUMENTS` contains a file path, use that. Otherwise, check for a file open in the IDE selection context. If neither, ask the user what to scrutinize.

Read the artifact in full. If it references other files, note the file paths — but do NOT summarize them for the critic. The critic will pull its own context (see Step 1).

Parse `$ARGUMENTS` as: first token is the file path (or quoted path if it contains spaces), optional second token is the round count as an integer (default 2).

**Size check:** If the artifact exceeds ~500 lines, note this to the user before proceeding — the critique may be less thorough on large documents. Consider asking the user to narrow the scope.

### Step 1: Spawn the Critic (Fresh Context)

**Load the regularizer:** Read `.claude/agents/regularizer.md`. Prepend this constraint to the critic's prompt. The critic has no cognitive lens, so the regularizer provides an accuracy boost at zero compliance cost. Do NOT apply the regularizer to rebuttal-round critics in Step 3 — they already have structured context (prior critique + advocate response) that disrupts default generation.

Launch an Agent with `subagent_type: general-purpose`. The critic's prompt must:

1. **Include the full artifact text** (not a file path — the agent needs the content in its prompt to read it cold)
2. **Give the critic Read and Grep tool access** so it can pull its own codebase context. Do NOT provide facilitator-written summaries — this is the most important integrity rule. The critic's prompt should contain ONLY the artifact text, the codebase root path, and the critique instructions. Zero editorial framing.
3. **NOT include** the conversation history, the author's reasoning, or any context about how the artifact was created
4. **Scope the critic's tool use:** "You may use Read/Grep ONLY to verify claims made in the artifact or to check direct dependencies it references. Do not explore the codebase beyond what the artifact discusses. If you cannot verify a claim within this boundary, note it as unverifiable rather than expanding your search."
5. **Cap context gathering:** Read at most 10 referenced files, no individual file read longer than 300 lines. If more context seems needed, note what you couldn't verify and why.

Use this prompt structure for the critic:

```
You are a technical architecture reviewer. You've been given an artifact to critique. You have NO context about how or why it was created — you're reading it cold.

You have access to Read and Grep tools to verify claims in the artifact against the actual codebase at [codebase root path]. SCOPE CONSTRAINT: Only read files the artifact specifically references or makes claims about. Do not explore beyond direct dependencies. Cap at 10 files, 300 lines each. If you can't verify something within these bounds, note it as unverifiable.

Review the following document and produce a structured critique:

## What's Sound
What's well-designed, correctly reasoned, or well-structured? Be specific about why.

## What's Shaky
What has weak foundations, unvalidated assumptions, over-specified details, or hidden risks? For each issue:
- Name the specific problem
- Explain why it matters (not just that it exists)
- Suggest what would fix it

## What's Missing
What does the document fail to address that it should? Gaps in reasoning, unstated assumptions, missing failure modes, absent cost models, etc.

## Recommended Changes
Ordered list of concrete changes, prioritized by impact.

## Sequencing & Dependencies
Are the phases/steps ordered correctly? Are there hidden dependencies? Should anything move earlier or later?

Be direct. Don't soften criticism with qualifiers. If something is wrong, say it's wrong and say why.

---

ARTIFACT:

[full artifact text here]
```

### Step 2: Present the Critique

When the critic agent returns, present its output to the user verbatim under a header:

```
## Critic's Review (Fresh Eyes)

[critic output]
```

### Step 3: Dialogue Rounds

After presenting the critique, ask: **"Want to run a dialogue round? The advocate responds to the critique, then the critic gets a rebuttal."**

If yes (or if `$ARGUMENTS` specified rounds > 0), run dialogue rounds:

**Advocate round:** You (the facilitator, who has full conversation context) write a response to the critique on behalf of the artifact. Where the critique is right, concede specifically. Where it's wrong or missing context, push back with reasons. Where it's partially right, propose amendments. **If you helped create the artifact,** acknowledge this bias explicitly at the top of your advocate response and hold yourself to a higher standard of honesty — contested points where you are both author and advocate should be flagged for extra user scrutiny in the synthesis.

**Critic rebuttal:** Spawn a NEW Agent (fresh context again) with:
- The original artifact
- The critic's initial review
- The advocate's response
- Instruction: "Review the advocate's response. Where do you accept the pushback? Where do you hold your ground? Are there new concerns raised by the advocate's response?"

Present the rebuttal. Ask if the user wants another round. Default is 2 total rounds (initial critique + 1 dialogue round). Max 3 rounds — beyond that, diminishing returns.

### Step 4: Synthesis

After dialogue completes, produce a **Synthesis** section:

```
## Synthesis: What Changed

**Agreed changes** (both sides concur):
1. [change]
2. [change]

**Contested points** (unresolved — user decides):
1. [point] — Critic says X, Advocate says Y
2. [point] — Critic says X, Advocate says Y

**New insights from dialogue** (emerged during the exchange):
1. [insight]
```

### Step 5: Apply (Optional)

Ask: **"Want me to apply the agreed changes to the document?"**

If yes, edit the artifact with all agreed changes. Do NOT apply contested points — those need the user's call.

## Design Principles

- **Fresh context is the point.** The critic agent must never have the author's reasoning in its prompt. The whole value is the cold read. Never include facilitator-written summaries or editorial framing in the critic prompt — only the artifact text and instructions.
- **Rebuttal rounds serve a different purpose than the initial critique.** Round 1 is the cold read. Round 2+ the critic has seen the advocate's reasoning, which partially breaks the fresh-context guarantee. This is a known tradeoff — the rebuttal stress-tests the advocate's defenses rather than providing another cold read. Both are valuable, but they're different.
- **Specificity over vibes.** "This section is weak" is useless. "The retry formula uses arbitrary weights with no empirical basis" is useful.
- **The advocate earns concessions, not freebies.** Don't concede critique points to be agreeable. Push back where the critique is wrong or missing context. The dialogue is only valuable if both sides are honest.
- **Scope the artifact, not the universe.** The critic reviews what's in the document. It doesn't redesign the product, question the market, or suggest pivoting to a different idea. When the critic has tool access, scope is enforced: verify claims in the artifact and check direct dependencies only.
- **Rounds have diminishing returns.** 2 rounds finds 90% of the value. 3 rounds if the first round surfaced something fundamental. Never more than 3.
- **Graceful degradation.** If the artifact is large (500+ lines), warn the user. If the critic returns output missing the required sections, note the gap to the user rather than re-spawning (expensive). If the critic can't verify a claim within tool-access bounds, it should note it as unverifiable.
