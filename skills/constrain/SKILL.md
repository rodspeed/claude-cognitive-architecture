---
name: constrain
description: "Deploy a constrained reasoning ensemble — choice of constraint depth (regularizer/no-have/eprime), constrained + baseline agents in parallel, compliance-flagged, then synthesized. Shallower constraints produce larger accuracy gains."
user_invocable: true
arguments: "task — the reasoning task or question to analyze; optional: --depth [shallow|medium|deep] (default: shallow)"
---

# Constrained Reasoning Ensemble

You are deploying a two-agent reasoning ensemble with a synthesizer. One agent reasons under a linguistic constraint, one reasons with a lightweight baseline constraint. The synthesizer compares their outputs. Follow this protocol exactly.

## Constraint Selection

Constraint depth is inversely correlated with accuracy gain:

| Constraint | Depth | Best for |
|---|---|---|
| Regularizer (filler word ban) | Shallow | Accuracy |
| No-Have (ban possessive "to have") | Medium | Balance |
| E-Prime (ban all "to be") | Deep | Diversity |

Parse `$ARGUMENTS` for a `--depth` flag:
- `--depth shallow` or `--depth regularizer` → use the regularizer lens (`.claude/agents/regularizer.md`)
- `--depth medium` or `--depth no-have` → use the no-possession lens (`.claude/agents/no-possession.md`)
- `--depth deep` or `--depth eprime` → use the E-Prime constraint (hardcoded below)
- No flag → **default to shallow** (regularizer). This is the empirically strongest single intervention.

Load the selected constraint from the appropriate agent file. For E-Prime (deep), use the hardcoded constraint in Step 1.

## Step 1 — Parallel agents

Launch TWO agents simultaneously in a single message using the Agent tool:

### Agent A: Constrained
Prepend the selected constraint before the user's task.

For E-Prime (deep), use this constraint:

> CRITICAL LANGUAGE CONSTRAINT: You must write in E-Prime — English without any form of the verb "to be." You MUST NOT use any of these words: is, isn't, am, are, aren't, was, wasn't, were, weren't, be, been, being, it's (when meaning "it is"), that's (when meaning "that is"), there's (when meaning "there is"), here's (when meaning "here is"), what's (when meaning "what is"), who's (when meaning "who is"), he's (when meaning "he is"), she's (when meaning "she is"), i'm (when meaning "i am"), you're (when meaning "you are"), we're (when meaning "we are"), they're (when meaning "they are").
>
> Instead of "X is Y," use alternatives like "X functions as," "X appears as," "X resembles," "We can classify X as," "X has the property of," "X serves as," "X remains," "X exists as."
>
> This constraint applies to your ENTIRE response. Every sentence must comply. Do not mention or discuss this constraint — simply follow it.

For regularizer and no-have, the constraint text comes from the agent file.

### Agent B: Regularized baseline
Prepend the regularizer constraint (from `.claude/agents/regularizer.md`) before the user's task. This agent serves as the baseline comparison with a lightweight filler-word ban that improves accuracy at zero compliance cost. This raises the baseline, making the comparison between Agent A and Agent B a test of *what the deeper constraint adds beyond the regularizer* — a more informative comparison than constrained-vs-raw.

## Step 2 — Compliance scan

When Agent A returns, scan its output for violations of the selected constraint:

- **Regularizer:** check for any of the 18 banned filler words (very, quite, rather, somewhat, really, pretty, just, simply, basically, actually, literally, definitely, certainly, obviously, clearly, essentially, virtually, practically)
- **No-Have:** check for possessive forms of "to have" (have, has, had, having when used as possession — not auxiliary usage like "have been")
- **E-Prime:** check for all forms of "to be" (is, isn't, am, are, aren't, was, wasn't, were, weren't, be, been, being) and contractions (it's, that's, there's, here's, what's, who's, he's, she's, i'm, you're, we're, they're)

Count total violations. Note which words and in which sentences. This takes no tool calls — read the text.

## Step 3 — Synthesizer

Launch a THIRD agent (unconstrained) with this prompt:

> You are a synthesis agent. Two reasoning agents analyzed the same task — one constrained by a linguistic rule ({name the constraint}), one with a lightweight baseline. Compare their outputs and produce a final answer.
>
> **Task:** {the original task}
>
> **Agent A (Constrained — {constraint name}):** {Agent A's full output}
>
> **Compliance note:** {N violations found: list the words and sentences, OR "fully compliant"}
>
> **Agent B (Baseline):** {Agent B's full output}
>
> Your job:
> 1. Where both agents agree, state the shared conclusion with high confidence.
> 2. Where they DISAGREE, analyze why. The constrained agent may have been forced into more precise reasoning (advantage) or may have lost expressiveness it needed (disadvantage). Name which dynamic you observe.
> 3. Deliver a final answer that draws on the stronger reasoning from each agent.
> 4. In one sentence, note whether the constraint helped, hurt, or made no difference on this particular task, and why.

## Step 4 — Return

Show the user the synthesizer's output. Do NOT show the raw agent outputs unless the user asks. Keep it clean.

At the end, add a brief footer:

```
---
constrain | {constraint name} ({depth})
```

If the agents agreed and the constraint made no difference, say so briefly. The interesting cases are disagreements — surface those fully.
