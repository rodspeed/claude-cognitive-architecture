#!/bin/bash
# Hook: Auto-format HTML files after Claude edits them
# Event: PostToolUse (matcher: Edit|Write)
#
# Strips trailing whitespace from every line and ensures
# the file ends with a single newline. Lightweight formatting
# that keeps HTML files clean without requiring a full formatter.
#
# Receives tool input as JSON on stdin. Only acts on .html files.

INPUT=$(cat)

python -c "
import json, sys, os

data = json.loads(sys.stdin.read())
file_path = data.get('tool_input', {}).get('file_path', '')

if not file_path or not file_path.endswith('.html'):
    sys.exit(0)

if not os.path.isfile(file_path):
    sys.exit(0)

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

lines = [line.rstrip() for line in content.splitlines()]
result = '\n'.join(lines)
if not result.endswith('\n'):
    result += '\n'

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(result)
" <<< "$INPUT" 2>/dev/null

exit 0
