#!/bin/bash
# Forget a fact: finds every line mentioning <text> in the memory files and deletes it.
# Usage: forget.sh "<text>"           -> preview only (default)
#        forget.sh "<text>" --apply   -> delete those lines (keeps one undo copy)
#        forget.sh --undo             -> restore the last forget
#        forget.sh --purge            -> erase the undo copy for good
# Does not touch deadlines.md or jobs.md (use those skills to change them).
TERM_="$1"; MODE="${2:-}"
W="${WORKSPACE:-/sandbox/.openclaw/workspace}"
cd "$W" || exit 1
UNDO=.forget-undo
if [ "$TERM_" = "--undo" ]; then
  [ -d "$UNDO" ] || { echo "Nothing to undo."; exit 0; }
  (cd "$UNDO" && find . -type f) | while read -r f; do cp "$UNDO/$f" "$f"; done
  rm -rf "$UNDO"; openclaw memory index >/dev/null 2>&1; echo "RESTORED: the last forget was undone."; exit 0
fi
if [ "$TERM_" = "--purge" ]; then rm -rf "$UNDO"; echo "PURGED: the undo copy is erased."; exit 0; fi
if [ ${#TERM_} -lt 3 ]; then echo "Give at least 3 characters to forget."; exit 1; fi
FILES=$(ls MEMORY.md USER.md DREAMS.md memory/*.md 2>/dev/null; find memory/dreaming memory/.dreams -type f 2>/dev/null)
HITS=$(grep -n -i -F -- "$TERM_" $FILES 2>/dev/null)
if [ -z "$HITS" ]; then echo "NOTHING_FOUND: no memory mentions \"$TERM_\"."; exit 0; fi
echo "MATCHES: $(echo "$HITS" | wc -l | tr -d ' ') lines"
echo "BY FILE:"
echo "$HITS" | cut -d: -f1 | sort | uniq -c | awk '{print "  " $2 ": " $1 " lines"}'
echo "EXAMPLES:"
echo "$HITS" | head -5 | cut -d: -f3- | cut -c1-120 | sed 's/^/  - /'
if [ "$MODE" != "--apply" ]; then echo "PREVIEW_ONLY: run again with --apply to delete these lines."; exit 0; fi
rm -rf "$UNDO"
for f in $(echo "$HITS" | cut -d: -f1 | sort -u); do
  mkdir -p "$UNDO/$(dirname "$f")"; cp "$f" "$UNDO/$f"
  grep -v -i -F -- "$TERM_" "$f" > "$f.tmp"; cat "$f.tmp" > "$f"; rm -f "$f.tmp"
done
openclaw memory index >/dev/null 2>&1 && echo "Search index rebuilt."
echo "DELETED: all lines above."
echo "UNDO_AVAILABLE: say \"undo forget\" to restore, or \"erase for good\" to purge the undo copy."
echo "Note: old chat transcripts can still mention it. To remove a whole session: nemoclaw my-assistant sessions delete <key>"
