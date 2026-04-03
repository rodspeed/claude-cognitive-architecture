# Memory System Structure

The memory system uses a file-based directory layout. Each category stores a different type of long-term knowledge.

## Directory Layout

```
memory/
  user/                    # Who the user is
    identity.md            #   Background, heritage, education, cognitive style
    drives.md              #   Motivations, values, working patterns
    creative-life.md       #   Projects, creative output, professional identity
    observations.md        #   Raw behavioral evidence log (from Observe skill)
    tensions.md            #   Contradiction log (belief A vs. observation B)
    session-counter.json   #   Session count, last review date, next review trigger
    epistemic-protocol.md  #   Rules for belief management (see memory/epistemic-protocol.md)

  feedback/                # How to collaborate
    all.md                 #   Communication style, preferences, corrections, validated approaches

  projects/                # What's being worked on
    {project-name}.md      #   Status, decisions, blockers, timelines per project

  reference/               # Where to find things
    {resource-name}.md     #   Pointers to external systems, dashboards, tools
```

## Belief Format

Each belief in a user profile file follows this structure:

```markdown
### Belief name
{Description of the belief}

- **conf:** 0.65
- **perm:** durable
- **first:** 2026-03-15
- **confirmed:** 2026-03-28
- **challenged:** —
```

## Key Rules

1. **Beliefs are hypotheses, not facts.** Confidence is earned through observation, not assigned by salience.
2. **Contradictions create tensions, not overwrites.** When behavior contradicts a belief, both are logged.
3. **Dormancy decay is automatic.** Beliefs attenuate over time based on permanence class.
4. **Observations promote to beliefs slowly.** 2+ observations of the same pattern → belief at 0.30–0.40 confidence.
5. **Not every session updates the profile.** Only update beliefs actively relevant to the current session.

## Getting Started

1. Create the directory structure above
2. Copy `epistemic-protocol.md` into your memory root
3. Start with empty profile files — beliefs accumulate naturally through the Observe and Mirror skills
4. The session counter triggers periodic reviews every 10 sessions
