# Claude Cognitive Architecture

Nine cognitive lenses, three functional roles, and an ensemble architecture for Claude Code.

Most people customize what their AI knows. This project customizes **how it thinks** — structural constraints that change reasoning patterns, not just surface vocabulary.

**Blog post:** [Cognitive Lenses for Claude Code](https://rodspeed.ai/blog/cognitive-architecture.html)

## What's in here

```
agents/
  counterfactual.md    # lens — invert assumptions, find hidden dependencies
  analogical.md        # lens — map findings to cross-domain parallels
  minimal.md           # lens — absolute minimum words
  evidential.md        # lens — tag every claim with epistemic source
  first-principles.md  # lens — derive from axioms only
  steel-man.md         # lens — strongest defense of status quo first
  eprime.md            # lens — ban "to be," force operational language
  process-only.md      # lens — everything as flow and transformation
  no-possession.md     # lens — strip "to have," describe through relationships
  critic.md            # role — fresh-context adversarial reviewer
  researcher.md        # role — deep investigation with provenance
  synthesizer.md       # role — unify multiple agent outputs
```

## Two types of agents

**Lenses** (`type: lens`) change *how* an agent thinks. They're cognitive constraints prepended to an agent's prompt. The model never sees the word "lens" — it just receives a constraint that shapes its reasoning.

**Roles** (`type: role`) define *what* an agent does. They're full prompt templates with structured output formats and tool requirements.

Lenses and roles compose. A researcher with the *evidential* lens tags every finding with its source. A researcher with the *counterfactual* lens probes what changes if key assumptions are wrong. Same role, different cognitive approach, different output.

## Quick start

### 1. Copy the agents directory

```bash
cp -r agents/ .claude/agents/
```

### 2. Use a lens manually

Tell Claude Code:

> Read the constraint in `.claude/agents/counterfactual.md` and apply it to this question: [your question]

That's it. See if the constrained analysis reveals something the default response missed.

### 3. Run two lenses on the same question

> Read `.claude/agents/counterfactual.md` and `.claude/agents/steel-man.md`. Spawn two agents in parallel — one with each constraint — analyzing this question: [your question]. Then compare what each one caught.

### 4. Build a skill (optional)

When you find a combination you keep reaching for, wrap it in a skill (`.claude/skills/yourskill/SKILL.md`) that reads the agent files and spawns parallel agents automatically. See the `examples/` directory for a minimal parallax-style skill.

## File format

```markdown
---
name: counterfactual
type: lens
description: Inverts assumptions to find hidden dependencies
---

For every claim or observation, systematically explore
what would break if the opposite were true.

Structure: observation → inversion → what breaks.
```

- YAML frontmatter: `name`, `type` (lens or role), `description`
- Body: the constraint text (for lenses) or full prompt template (for roles)
- Skills read agent files at runtime and inject the body into agent prompts

## Adding a new lens

Create a markdown file in `agents/` with `type: lens` in the frontmatter. Write one paragraph describing the cognitive constraint. That's a complete lens — no other files need editing.

## Ensemble patterns

These agents are designed to be composed into ensembles by skills. Three patterns work well:

**Multi-lens analysis** — Run 3 lensed agents on the same question in parallel, then synthesize. Good for architecture decisions, code review, debugging.

**Parallel deep research** — Decompose a question into facets, assign each to a researcher agent (optionally with a lens), synthesize findings.

**Adversarial review** — A critic reads a document cold (no author context), an advocate responds, a new critic rebuts. Two rounds, then synthesis.

## Related work

- [Umwelt Engineering](https://github.com/rodspeed/umwelt-engineering) — the research framework behind this: designing the linguistic world an AI agent can think in
- [Epistemic Memory](https://github.com/rodspeed/epistemic-memory) — persistent memory with confidence tracking, decay, and contradiction tolerance

## License

MIT
