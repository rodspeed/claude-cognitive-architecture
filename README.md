# Claude Code Cognitive Infrastructure

Five architectural layers that turn Claude Code from a single-turn CLI into a multi-session cognitive system — with parallel reasoning ensembles, empirically validated linguistic constraints, epistemic memory, adversarial self-review, and reflexive observation.

**No custom APIs. No model modifications. Just markdown files, shell hooks, and the extension points Claude Code already provides.**

**Blog post:** [The Full Stack: A Cognitive Operating System Inside Claude Code](https://rodspeed.ai/blog/infrastructure-guide.html)

---

## Table of Contents

1. [The Five Layers](#the-five-layers)
2. [Layer 1: Orchestration Skills](#layer-1-orchestration-skills)
3. [Layer 2: Cognitive Lenses](#layer-2-cognitive-lenses)
4. [Layer 3: Epistemic Memory](#layer-3-epistemic-memory)
5. [Layer 4: Reflection](#layer-4-reflection)
6. [Layer 5: Hooks & Automation](#layer-5-hooks--automation)
7. [Composition Patterns](#composition-patterns)
8. [Quick Start](#quick-start)
9. [Extending the System](#extending-the-system)
10. [Design Principles](#design-principles)
11. [Empirical Grounding](#empirical-grounding)
12. [Related Work](#related-work)

---

## The Five Layers

Each layer depends on the ones below it but can function independently. Adopt just the lenses, or just the memory system, or just the adversarial review skill. They compose, but they don't require each other.

```
┌─────────────────────────────────────────────────────────┐
│  05  HOOKS & AUTOMATION                                 │
│      Shell triggers + instruction-level auto-behaviors  │
├─────────────────────────────────────────────────────────┤
│  04  REFLECTION                                         │
│      Mirror, Harvest, Observe — self-watching machinery │
├─────────────────────────────────────────────────────────┤
│  03  EPISTEMIC MEMORY                                   │
│      Beliefs with confidence, decay, and tensions       │
├─────────────────────────────────────────────────────────┤
│  02  COGNITIVE LENSES                                   │
│      Language constraints that reshape reasoning        │
├─────────────────────────────────────────────────────────┤
│  01  ORCHESTRATION SKILLS                               │
│      Skills that deploy parallel agent teams            │
└─────────────────────────────────────────────────────────┘
```

---

## Layer 1: Orchestration Skills

A skill is a slash command. Type `/parallax` or `/research` and it expands into a multi-step plan that spawns agents, coordinates their work, and synthesizes the output. The user-facing interface is one word. The machinery behind it can involve 3–5 parallel agents converging into a single synthesized answer.

```
                        ┌──────────┐
                        │  Orient  │  ← "which tool fits this problem?"
                        └────┬─────┘
              ┌──────────┬───┴────┬───────────┐
              ▼          ▼        ▼            ▼
         ┌─────────┐ ┌────────┐ ┌──────────┐ ┌───────────┐
         │Research  │ │Parallax│ │Constrain │ │Scrutinize │
         └────┬─────┘ └───┬────┘ └────┬─────┘ └─────┬─────┘
              │           │           │              │
        ┌─────┼─────┐  ┌──┼──┐    ┌───┼───┐     ┌───┼───┐
        ▼     ▼     ▼  ▼  ▼  ▼   ▼       ▼     ▼       ▼
       F1    F2    F3  L1 L2 L3  CON    BASE   CRIT    ADV
        └─────┼─────┘  └──┼──┘    └───┼───┘     └───┼───┘
              └────────────┼──────────┼─────────────┘
                           ▼          ▼
                    ┌──────────────────────┐
                    │     Synthesizer      │
                    │ blind spots •        │
                    │ divergences •        │
                    │ consensus            │
                    └──────────────────────┘
```

### The five skills

| Skill | Command | Pattern | What it does |
|-------|---------|---------|-------------|
| **Orient** | `/orient "problem"` | 1 agent (self) | Chief of staff. Surveys the full toolkit and recommends a deployment strategy. Doesn't execute — teaches you your own tools. |
| **Research** | `/research "question"` | 2–5 parallel | Decomposes into independent facets, spawns a researcher per facet, synthesizes. Prevents groupthink through isolation. |
| **Parallax** | `/parallax --profile architecture "question"` | 3 parallel + synth | Runs the same query through 3 cognitively diverse lenses simultaneously. Maps blind spots, divergences, and consensus. |
| **Constrain** | `/constrain --depth shallow "task"` | 2 parallel + synth | Tests how a linguistic constraint affects reasoning. Constrained agent vs. baseline, side by side. |
| **Scrutinize** | `/scrutinize artifact.md` | 2-round dialogue | Fresh-context adversarial review. Critic reads cold, advocate responds, points resolve into agreed changes vs. contested points. |

The common pattern: spawn diverse agents in parallel, let them work independently, then synthesize. The synthesis step is where the real value lives.

→ See [`skills/`](skills/) for full skill definitions

---

## Layer 2: Cognitive Lenses

A lens is a markdown file that describes a cognitive constraint. When a skill runs, it reads the file and prepends the constraint to the agent's prompt. The model never sees the word "lens." It just receives a rule that shapes how it approaches the task.

### Two families

**Vocabulary constraints** ban specific words or structures, forcing the model to route around defaults:

| Constraint | Bans | Accuracy Gain | Compliance Cost |
|-----------|------|:------------:|:---------------:|
| **Regularizer** | 18 filler words (*very, quite, basically, obviously*...) | **+7.3pp** | Trivial |
| **No-Have** | Possessive "to have" (*has, have, had* as ownership) | **+5.4pp** | Low |
| **E-Prime** | All forms of "to be" (*is, are, was, were, been*) | **+3.7pp** | High (45.6% retry) |

> **The lightest constraint wins.** Banning 18 filler words (+7.3pp) outperforms banning all forms of "to be" (+3.7pp). Shallow constraints disrupt the model's "fluency autopilot" — the pattern of generating smooth text that papers over analytical gaps. Deep constraints produce more *diverse* reasoning but aren't as reliably more *accurate*.

**Reasoning modifiers** prescribe analytical frameworks without touching vocabulary:

| Lens | Constraint |
|------|-----------|
| **Counterfactual** | For every assumption, explore what breaks if it were false |
| **Analogical** | Map findings to cross-domain parallels before stating them directly |
| **Minimal** | Absolute minimum words. Every word earns its place or gets cut |
| **Evidential** | Tag every claim: `[observed]`, `[inferred]`, `[assumed]`, `[uncertain]` |
| **First Principles** | Derive from axioms only. No conventions, no best practices |
| **Process-Only** | Everything as process, flow, and transformation. Nothing "is" anything |
| **Steel-Man** | Build the strongest defense of the status quo before finding where it fails |

### Regularizer auto-application

The regularizer (+7.3pp) auto-applies to every **unlensed** agent. When a lens is already active, it's skipped — lenses already disrupt default patterns, so stacking doesn't add value.

```
/research                        → researchers get regularizer (auto)
/research --lens counterfactual  → researchers get counterfactual only (no regularizer)
/parallax --profile debug        → 3 agents get profile lenses (no regularizer)
```

### Parallax profiles

Pre-configured lens combinations for specific problem types:

| Profile | Lens 1 | Lens 2 | Lens 3 | Best for |
|---------|--------|--------|--------|----------|
| `debug` | Counterfactual | Analogical | Minimal | Root cause analysis |
| `code-review` | Counterfactual | Minimal | Evidential | Diffs and PRs |
| `architecture` | First Principles | Process-Only | Steel-Man | Design decisions |
| `decision` | Counterfactual | First Principles | Steel-Man | Choices under uncertainty |
| `writing` | No-Possession | Evidential | Minimal | Prose improvement |
| `regularize` | Regularizer | Counterfactual | First Principles | Accuracy-optimized |

→ See [`agents/`](agents/) for all lens and role definitions

---

## Layer 3: Epistemic Memory

Most AI memory systems work like append-only logs: save facts, retrieve facts. This one works like a belief system. Every stored piece of knowledge carries metadata about *how confident the system should be in it* — and that confidence changes over time.

### Beliefs, not facts

```yaml
belief: "Prefers bundled PRs over many small ones for refactors"
conf: 0.65            # developing — seen twice, could be situational
permanence: durable   # working pattern, ~year timescale
first: 2026-03-15
confirmed: 2026-03-28 # last session consistent with this
challenged: null      # nothing contradicted it yet
```

**Confidence scale:**

| Range | Level | Meaning |
|-------|-------|---------|
| 0.9–1.0 | Factual | Verified facts only; almost nothing interpretive |
| 0.7–0.8 | Established | Consistent across many sessions; revisable |
| 0.5–0.6 | Developing | Pattern forming; could be situational |
| 0.3–0.4 | Tentative | Observed 1–2 times |
| 0.0–0.2 | Speculative | Inferred, not observed |

Confidence is *earned* through repeated observation, not assigned by how insightful a belief sounds.

### Dormancy decay

If the system goes dormant (30+ days without sessions), beliefs attenuate exponentially based on permanence class:

```
effective_conf = conf × e^(-λ × days_dormant)        floor: 0.20
```

| Permanence | Half-life | λ | Example |
|-----------|-----------|---|---------|
| **Stable** | ~2 years | 0.001 | Heritage, deep values, cognitive architecture |
| **Durable** | ~5 months | 0.005 | Working patterns, preferences, relationships |
| **Situational** | ~6 weeks | 0.015 | Current feelings, project motivations |

```
After 6 months dormant:
  stable belief (0.80)      → effective 0.67  ████████████████░░░░
  durable belief (0.80)     → effective 0.33  ████████░░░░░░░░░░░░
  situational belief (0.80) → effective 0.20  █████░░░░░░░░░░░░░░░  (floor)
```

### Tensions, not overwrites

When new observations contradict existing beliefs, the system creates a **tension** — a dated record saying "belief A and observation B don't agree, and we're watching." Real people are contradictory. A profile that fits too neatly is probably just a comfortable reduction.

→ See [`memory/`](memory/) for the memory system structure and epistemic protocol

---

## Layer 4: Reflection

The memory system stores beliefs. The reflection layer *maintains* them — the self-watching machinery that keeps the belief system honest over time.

### Observe

Runs at two speeds simultaneously:

| Mode | Trigger | Frequency | Purpose |
|------|---------|-----------|---------|
| **Live** | Judgment call, pushback, contradiction, unprompted reveal | Max 1 per trigger | Real-time evidence capture |
| **Harvest** | End of every substantive session | 0–3 per session | Backstop for what live mode missed |

Observation format:

```
Evidence:    User pushed back on splitting the PR, said "one bundled PR is the right call."
Suggests:    Prefers pragmatic grouping over conventional small-PR discipline for refactors.
Therefore:   Default to bundled PRs for refactors unless scope is truly independent.
Connects to: PR-style preference (new)
Strength:    single
```

Quality gate: nothing gets written unless the `Therefore` field would change future behavior.

### Mirror

Four modes that run on cadence (every 10 sessions or monthly):

| Mode | Purpose |
|------|---------|
| **Portrait** | Prose character study with blind spots and contradictions |
| **Audit** | Epistemological dashboard: confidence distributions, drift, staleness |
| **Gut-check** | Quick validation of 6 beliefs (3 strongest, 3 weakest) |
| **Interview** | 8–12 structured questions generated from blind spots and tensions |

Portrait mode also **promotes observations to beliefs**: when 2+ observations cluster around the same pattern, they graduate to a belief at low initial confidence (0.30–0.40). The system learns, but slowly and skeptically.

### Harvest

End-of-session knowledge extraction. Scans the conversation for insights and decisions, proposes them as new or updated knowledge graph entries, then runs Observe as its final step — making it a single atomic operation: extract knowledge *and* collect behavioral evidence.

→ See [`skills/`](skills/) for Mirror, Harvest, and Observe skill definitions

---

## Layer 5: Hooks & Automation

Shell hooks fire on specific events. Instruction-level auto-behaviors handle the rest.

| Trigger | Hook | What it does |
|---------|------|-------------|
| `SessionStart` | `load-handoff.sh` | Detects pending session handoffs, picks up where last session left off |
| `SessionStart` | `reinject-context.sh` | Re-injects CLAUDE.md after context compaction in long conversations |
| `Pre-Edit/Write` | `protect-files.sh` | Prevents accidental writes to locked/protected files |
| `Post-Edit/Write` | `auto-format-html.sh` | Formats HTML files consistently after every change |
| `Completion` | `notify.sh` | Desktop notification (async) |
| End of session* | Auto-harvest | Extracts knowledge + observes (instruction-level, in CLAUDE.md) |
| Mid-session* | Live observe | Ambient behavioral evidence collection (instruction-level) |

*\*Instruction-level auto-behaviors (defined in CLAUDE.md) rather than shell hooks. The distinction: shell hooks are deterministic triggers; instruction-level behaviors are probabilistic but pervasive.*

### Handoff

When a session ends with work in progress, the handoff skill packages context into `.claude/handoff.md` — mission, decisions, key files, current state, open tasks, gotchas, and next step. A fresh session picks this up automatically via the `load-handoff.sh` hook.

→ See [`hooks/`](hooks/) for hook scripts, [`skills/handoff/`](skills/handoff/) for the handoff skill

---

## Composition Patterns

Skills, lenses, memory, and hooks compose into repeatable pipelines.

### Analysis pipeline

```
Orient  →  Research  →  Parallax  →  Decision
(select)   (gather)     (triangulate)  (you decide)
```

Orient selects the right tools. Research gathers evidence across facets. Parallax triangulates through diverse lenses. You decide with the full picture.

### Production pipeline

```
Build  →  Scrutinize  →  Revise  →  Harvest
(create)   (adversarial)  (apply)    (extract knowledge)
```

Build the artifact. Scrutinize with fresh-context adversarial review. Apply agreed changes. Harvest extracts what you learned.

### Learning loop (cross-session)

```
 ┌──────────────┐     ┌──────────┐     ┌──────────┐     ┌──────────────┐
 │ Conversation │ ──▶ │ Observe  │ ──▶ │ Harvest  │ ──▶ │ Observations │
 └──────┬───────┘     └──────────┘     └──────────┘     └──────┬───────┘
        ▲                                                       │
        │    every session ▲              every ~10 sessions ▼  │
        │                                                       ▼
 ┌──────┴───────┐                                       ┌──────────┐
 │   Beliefs    │ ◀──────────────────────────────────── │  Mirror   │
 └──────────────┘                                       └──────────┘
```

Conversations produce observations. Observations accumulate. Mirror synthesizes them into belief updates. Beliefs inform future conversations. Tensions (contradictions) are held rather than smoothed over.

---

## Quick Start

### 1. Copy the agents directory

```bash
cp -r agents/ .claude/agents/
```

This gives you all 10 lenses and 3 roles. They work immediately.

### 2. Try a lens manually

Tell Claude Code:

> Read the constraint in `.claude/agents/counterfactual.md` and apply it to this question: [your question]

Compare the output to an unconstrained response. The difference is structural, not cosmetic.

### 3. Run two lenses side by side

> Read `.claude/agents/counterfactual.md` and `.claude/agents/steel-man.md`. Spawn two agents in parallel — one with each constraint — analyzing: [your question]. Then compare.

### 4. Add a skill

Copy a skill from [`skills/`](skills/) to `.claude/skills/`. For example:

```bash
cp -r skills/parallax/ .claude/skills/parallax/
```

Now `/parallax "your question"` works as a slash command.

### 5. Set up memory (optional)

Create the memory directory structure:

```bash
mkdir -p .claude/memory/user .claude/memory/feedback .claude/memory/projects
```

Add the epistemic protocol from [`memory/epistemic-protocol.md`](memory/epistemic-protocol.md) to guide how beliefs are stored and maintained.

### 6. Add hooks (optional)

Copy hook scripts from [`hooks/`](hooks/) to `.claude/hooks/` and register them in your `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "command": "bash .claude/hooks/load-handoff.sh" }
    ],
    "PreToolUse": {
      "Edit|Write": [
        { "command": "bash .claude/hooks/protect-files.sh \"$TOOL_INPUT\"" }
      ]
    }
  }
}
```

---

## Extending the System

The architecture grows by file addition. No code edits required.

| To add... | Create this file | Effect |
|-----------|-----------------|--------|
| New lens | `agents/my-lens.md` with `type: lens` | Immediately available to Parallax, Research, Constrain, Orient |
| New skill | `skills/my-skill/SKILL.md` with trigger + instructions | Available as `/my-skill` |
| New Parallax profile | Edit `skills/parallax/SKILL.md` profile table | New 3-lens combo for specific problem types |
| New memory category | `memory/category/INDEX.md` | Memory routing auto-discovers it |

### Lens file format

```markdown
---
name: my-constraint
type: lens
description: One line explaining what this constraint does
---

The constraint text. This gets prepended to the agent's prompt.
Keep it to 1–3 paragraphs. Be specific about what the agent
must do differently. Don't explain why — just state the rule.
```

### Role file format

```markdown
---
name: my-role
type: role
description: What this agent does
tools: [Read, Grep, Glob, WebSearch]
---

Full prompt template. Define the agent's job, methodology,
output format, and constraints. Roles are more detailed
than lenses — they define complete behavioral patterns.
```

---

## Design Principles

Eight principles that survived contact with daily use:

1. **Composition over monoliths.** Skills orchestrate agents. Agents are parameterized by lenses. Small, recombinant pieces scale better than feature-rich single tools.

2. **Parallel execution by default.** Research, Parallax, and Constrain spawn simultaneous agents. Fresh contexts prevent groupthink. Serial execution is the exception.

3. **Shallow constraints beat deep ones.** The biggest empirical surprise. Banning 18 filler words (+7.3pp) outperforms banning all forms of "to be" (+3.7pp). The regularizer auto-applies to every unlensed agent as a free accuracy boost.

4. **Confidence is earned, not assigned.** Beliefs start low and climb through confirming observations. Dormancy decay makes staleness visible. Contradictions create tensions rather than silent overwrites.

5. **Behavior over self-report.** The observe skill tracks what users *do* under pressure, not what they say about themselves. When the two diverge, a tension is logged.

6. **Fresh-context critique as default.** Scrutinize's critic has no creation history. It reads the artifact cold. This eliminates author bias.

7. **The directory is the interface.** New capabilities are files, not code changes. The system grows by addition, is inspectable (read the files), forkable (copy the directory), and collaborative (PRs are just markdown changes).

8. **Reflexive observation.** The system observes itself observing the user. Live observation + harvest backstop create a dual-loop learning system with no external auditor required.

---

## Empirical Grounding

The vocabulary constraints are validated by a 15,600-trial controlled experiment across 6 frontier models (Claude Sonnet, Haiku, Gemini, GPT-4o-mini, and others). The paper, "Cognitive Restructuring in Frontier Language Models," covers:

- **130 analytical items × 5 conditions × 6 models × 5 stochastic replications** + deterministic baselines
- Statistically significant accuracy gains (p < 0.001 by Fisher's exact test)
- The inverse depth–accuracy relationship: shallower constraints produce larger accuracy gains
- Qualitative analysis of how constraints restructure reasoning patterns

The theoretical framework is [**Umwelt Engineering**](https://github.com/rodspeed/umwelt-engineering) — designing the linguistic world an AI agent can think in. Lenses implement umwelt constraints: by restricting vocabulary and conceptual patterns, you reshape the model's cognitive landscape.

---

## What's in this repo

```
agents/                         # Cognitive agents (lenses + roles)
  counterfactual.md             #   lens — invert assumptions
  analogical.md                 #   lens — cross-domain mapping
  minimal.md                    #   lens — absolute minimum words
  evidential.md                 #   lens — tag epistemic sources
  first-principles.md           #   lens — derive from axioms only
  steel-man.md                  #   lens — defend status quo first
  eprime.md                     #   lens — ban "to be"
  process-only.md               #   lens — everything as flow
  no-possession.md              #   lens — strip possessive "to have"
  regularizer.md                #   lens — ban 18 filler words (+7.3pp)
  critic.md                     #   role — fresh-context adversarial reviewer
  researcher.md                 #   role — deep investigation with provenance
  synthesizer.md                #   role — unify multiple agent outputs

skills/                         # Orchestration skills (slash commands)
  orient/SKILL.md               #   chief of staff — tool selection
  parallax/SKILL.md             #   multi-lens triangulation
  research/SKILL.md             #   parallel deep investigation
  constrain/SKILL.md            #   constraint testing (2 agents)
  scrutinize/SKILL.md           #   adversarial architecture review
  mirror/SKILL.md               #   portrait, audit, gut-check, interview
  harvest/SKILL.md              #   knowledge extraction + observe
  observe/SKILL.md              #   behavioral evidence collection
  handoff/SKILL.md              #   session context packaging
  memba/SKILL.md                #   quick-save memory routing

hooks/                          # Shell hook scripts
  load-handoff.sh               #   session start — detect pending handoff
  reinject-context.sh           #   session start — re-inject after compaction
  protect-files.sh              #   pre-edit — guard locked files
  auto-format-html.sh           #   post-edit — format HTML

memory/                         # Epistemic memory system
  epistemic-protocol.md         #   rules for belief management
  structure.md                  #   directory layout guide

examples/                       # Starter examples
  minimal-parallax.md           #   stripped-down parallax skill
  settings.json                 #   hook configuration example
```

## Related work

- [Umwelt Engineering](https://github.com/rodspeed/umwelt-engineering) — the research framework: designing the linguistic world an AI agent can think in
- [Epistemic Memory](https://github.com/rodspeed/epistemic-memory) — standalone memory system with confidence tracking, decay, and contradiction tolerance

## License

MIT
