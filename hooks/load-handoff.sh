#!/bin/bash
# Hook: Auto-detect pending handoff on session start
# Event: SessionStart (no matcher — runs on every session start)
# Purpose: If a previous session left a handoff memo, alert Claude Code
#          to read it and continue the work.

HANDOFF="$CLAUDE_PROJECT_DIR/.claude/handoff.md"

if [ -f "$HANDOFF" ]; then
  if grep -q "status: pending" "$HANDOFF" 2>/dev/null; then
    echo ""
    echo "SESSION HANDOFF DETECTED — a previous session left context for you."
    echo "Read .claude/handoff.md immediately and continue the work described there."
    echo ""
    cat "$HANDOFF"
  fi
fi

exit 0
