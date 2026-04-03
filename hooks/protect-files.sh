#!/bin/bash
# Hook: Protect sensitive files from accidental edits
# Event: PreToolUse (matcher: Edit|Write)
# Exit 2 = block the action, exit 0 = allow
#
# Receives tool input as JSON on stdin. Checks the file_path against
# a set of protected filenames and path segments. Uses Python to parse
# JSON (avoids requiring jq as an external dependency).
#
# To customize: add filenames to protected_names or path patterns
# to the path-segment checks below.

INPUT=$(cat)

python -c "
import json, sys, os

data = json.loads(sys.stdin.read())
file_path = data.get('tool_input', {}).get('file_path', '')

if not file_path:
    sys.exit(0)

# --- Protected filenames (exact basename match) ---
basename = os.path.basename(file_path)
protected_names = {
    '.env',
    '.env.local',
    '.env.production',
    'credentials.json',
    'package-lock.json',
}

if basename in protected_names:
    print(
        f\"BLOCKED: Cannot edit '{file_path}' — '{basename}' is a protected file. \"
        f\"Ask the user for explicit permission first.\",
        file=sys.stderr,
    )
    sys.exit(2)

# --- Protected path segments ---
normalized = file_path.replace('\\\\', '/')
if '/.git/' in normalized or normalized.endswith('/.git'):
    print(
        f\"BLOCKED: Cannot edit '{file_path}' — .git/ is protected. \"
        f\"Ask the user for explicit permission first.\",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
" <<< "$INPUT"
