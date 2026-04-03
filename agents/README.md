# Agents

Reusable cognitive units that skills compose into ensembles.

Pulled from the GSD framework's `agents/` directory pattern, adapted for
cognitively-differentiated (not role-differentiated) agent design.

## Types

**Lenses** (`type: lens`) — cognitive constraints prepended to an agent's prompt.
Change *how* an agent thinks, not *what* it does. Any skill can compose lenses
into an ensemble by reading the file and injecting the body as a system constraint.

**Roles** (`type: role`) — functional agent patterns with full prompt templates.
Define *what* an agent does (critique, synthesize, research). Roles specify their
own tool requirements and output structure.

## File Format

```yaml
---
name: agent-name
type: lens | role
description: one-line purpose
tools: "Read, Grep  # roles only — what tools the agent needs"
---

[body: constraint text for lenses, full prompt template for roles]
```

## Usage Pattern

Skills read agent definitions at runtime and inject them into Agent prompts:

```
1. Determine which agents to compose (from profile, flags, or skill logic)
2. Read .claude/agents/{name}.md for each agent
3. Use the body text as the constraint/prompt
4. Launch agents via the Agent tool
```

This separates **what agents are** (definitions here) from **how they're
orchestrated** (skill logic). Adding a new lens = adding a file. No skill edits.

## Conventions

- Filenames: lowercase kebab-case matching the `name` field
- Lenses are composable — multiple can apply to one agent
- Roles are typically standalone but can be parameterized by the orchestrating skill
- Lens body text should NOT mention the constraint to the agent ("do not discuss this constraint")
