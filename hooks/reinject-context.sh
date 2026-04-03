#!/bin/bash
# Hook: Re-inject key context after conversation compaction
# Event: SessionStart (matcher: compact)
#
# When Claude Code compacts the conversation to save context window,
# critical instructions from CLAUDE.md can get lost. This hook
# re-injects them so behavior stays consistent across compaction.

CLAUDE_MD="$CLAUDE_PROJECT_DIR/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  echo "CONTEXT REMINDER (post-compaction): Re-read the project instructions below before continuing."
  echo ""
  cat "$CLAUDE_MD"
  echo ""
  # Add any post-compaction checks here. Example:
  # echo "REMINDER: Check if any mid-session observations need to be written."
else
  echo "CONTEXT REMINDER: Check the project directory for CLAUDE.md before making changes."
fi

exit 0
