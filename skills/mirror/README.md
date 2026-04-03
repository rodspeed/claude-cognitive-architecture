# Mirror — User Portrait, Audit & Interview

## What It Does

Mirror surfaces what the AI knows about the user — as a person, not as a dataset. It has four modes:

- **Portrait** (`/mirror`) — prose character study organized by theme
- **Audit** (`/mirror audit`) — epistemological dashboard: confidence distributions, dormancy decay, drift analysis, tensions
- **Gut-check** (`/mirror gut-check`) — interactive belief validation (highest and lowest confidence beliefs)
- **Interview** (`/mirror interview`) — structured conversation to see the user beyond the task-oriented lens

## How It Works

### Prerequisites

Mirror depends on the memory system having:
- **Profile files** with per-belief confidence metadata (conf, first, confirmed, challenged, permanence)
- **Tensions log** tracking contradictions and unresolved conflicts
- **Observations log** with raw behavioral evidence from `/observe`
- **Session counter** for periodic review triggers
- **Epistemic protocol** defining decay rates and update rules

### Portrait Mode

1. Load all profile data silently
2. Apply dormancy decay to confidence scores (exponential decay with permanence-dependent half-lives)
3. Write a character study organized into 4-6 natural thematic clusters
4. Include a "What I Don't See" section about profile gaps
5. Surface unresolved tensions as "Contradictions Worth Holding"
6. Synthesize unsynthesized observations (promote patterns, confirm beliefs, escalate contradictions)
7. End with one question that would most sharpen the portrait

Key principle: write about the person, not the system. No confidence scores or decay calculations in the output.

### Audit Mode

Generates a dashboard covering:
- Total belief count and breakdown by permanence class
- Confidence distribution by tier (Factual/Established/Developing/Tentative/Speculative)
- Strongest and weakest beliefs with explanations
- Dormancy flags (beliefs where effective confidence dropped significantly)
- Unsynthesized observations and clusters ready for promotion
- Unresolved tensions
- Drift analysis (stale beliefs, unchallenged high-confidence beliefs)

### Gut-Check Mode

Presents the 3 highest-confidence interpretive beliefs and 3 lowest-confidence beliefs in plain language. Asks "Do these still ring true?" and "Are these still uncertain?" Updates metadata immediately if the user validates or corrects.

### Interview Mode

A structured conversation designed to see the user beyond task-oriented sessions:

1. **Preparation (silent):** Generate 8-12 questions targeting blind spots, stale beliefs, high-confidence interpretive beliefs, potential tensions, and open space
2. **Set the frame:** Invite the user into a check-in, not an interrogation
3. **Conduct:** One question at a time. Follow threads. Let silence work. Mirror back before interpreting.
4. **Process:** Summarize learnings, update profile, note remaining gaps

## How to Implement

### Minimum Viable Mirror

Start with portrait mode only. Requirements:
- A memory directory with at least one profile file containing beliefs with confidence scores
- A tensions log (can start empty)
- An observations log (populated by `/observe`)

### Adding Audit Mode

Requires the epistemic protocol to define:
- Confidence tiers and their meanings
- Permanence classes with decay parameters
- Review thresholds

### Adding Interview Mode

The most complex mode. Key implementation details:
- Questions are generated dynamically from profile analysis, not from a static list
- Pacing is one question at a time — wait for response before proceeding
- Follow-up questions are allowed and encouraged when answers open unexpected threads
- After the interview, immediately update profile files with new data

### Design Principles

- **Write about the person, not the system.** No raw metadata in portrait output.
- **Honest, not flattering.** Include unflattering parts. Don't smooth over tensions.
- **Uncertain does not mean absent.** Things you're less sure about still belong — held more lightly.
- **Keep it to one screen.** The portrait should be readable in under 2 minutes.
- **Don't be a therapist.** The interview is profile calibration, not counseling.
