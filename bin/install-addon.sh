#!/bin/bash
# Adds the Study Copilot routing rules to the agent's AGENTS.md (read at every
# session start). Safe to re-run: replaces the block between its markers.
W="${WORKSPACE:-/sandbox/.openclaw/workspace}"
ADDON="$W/workspace/agents-addon.md"
[ -f "$ADDON" ] || ADDON="$(cd "$(dirname "$0")/.." && pwd)/workspace/agents-addon.md"
A="$W/AGENTS.md"
[ -f "$A" ] || { echo "No $A"; exit 1; }
[ -f "$A.orig" ] || cp "$A" "$A.orig"
python3 - "$A" "$ADDON" <<'PY'
import re, sys
path, addon_path = sys.argv[1], sys.argv[2]
text = open(path).read()
addon = open(addon_path).read().strip() + "\n"
text = re.sub(r"\n*<!-- study-copilot:start -->.*?<!-- study-copilot:end -->\n*", "\n\n", text, flags=re.S)
marker = "\n## Automations"
if marker in text:
    head, tail = text.split(marker, 1)
    text = head.rstrip("\n") + "\n\n" + addon + "\n## Automations" + tail
else:
    text = text.rstrip("\n") + "\n\n" + addon
open(path, "w").write(text)
PY
grep -q 'study-copilot:start' "$A" && echo "Routing rules installed in $A (original saved as AGENTS.md.orig)"
