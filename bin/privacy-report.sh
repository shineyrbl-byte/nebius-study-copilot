#!/bin/bash
# Shows everything the assistant remembers and every place your data lives.
# Read-only. No model call, so nothing in this report leaves the machine.
W="${WORKSPACE:-/sandbox/.openclaw/workspace}"
cd "$W" || exit 1
count() { local n; n=$(grep -c "${2:-.}" "$1" 2>/dev/null); echo "${n:-0}"; }
files() { [ -d "$1" ] && find "$1" -type f ! -name '.*' | wc -l | tr -d ' ' || echo 0; }

echo "== WHAT I REMEMBER ABOUT YOU =="
echo "-- MEMORY.md (long-term facts):"
[ -s MEMORY.md ] && sed 's/^/  /' MEMORY.md || echo "  (empty)"
echo
echo "-- USER.md (your preferences):"
P=$(sed -n '/^## Directives/,/^## Related/p' USER.md 2>/dev/null | grep '^- ' | grep -v '^- Prefer \.\.\.$')
[ -n "$P" ] && echo "$P" | sed 's/^/  /' || echo "  (none saved)"
echo
echo "-- Daily notes (memory/YYYY-MM-DD.md):"
ls memory/*.md 2>/dev/null | while read -r f; do
  echo "  $f ($(count "$f") lines)"; head -5 "$f" | sed 's/^/      /'
done
[ -z "$(ls memory/*.md 2>/dev/null)" ] && echo "  (none)"
echo
echo "== YOUR DATA FILES =="
echo "  deadlines.md: $(count deadlines.md '| open') open, $(count deadlines.md '| done') done"
echo "  jobs.md: $(count jobs.md) applications"
echo "  inbox/: $(files inbox) files   summaries/: $(files summaries)   briefs/: $(files briefs)   plans/: $(files plans)   flashcards/: $(files flashcards)"
echo
echo "== COPIES MADE BY BACKGROUND MEMORY =="
echo "  DREAMS.md: $(count DREAMS.md) lines   memory/dreaming/: $(files memory/dreaming) files   memory/.dreams/: $(files memory/.dreams) files"
echo
echo "== WHERE YOUR DATA CAN GO =="
echo "  Model calls: Nebius Token Factory only (Nemotron Nano / Super / Ultra)."
echo "  Extra network access turned on in the sandbox policy:"
A=$(sed -n '/^## Active presets/,/^## /p' POLICY.md 2>/dev/null | grep '^- ' )
[ -n "$A" ] && echo "$A" | sed 's/^/    /' || echo "    (unknown: POLICY.md missing)"
echo "  Everything else is blocked by OpenShell."
