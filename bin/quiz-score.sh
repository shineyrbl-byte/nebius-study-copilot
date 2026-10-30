#!/bin/bash
# Records one quiz answer and keeps today's running score in flashcards/scores.md,
# so the score is saved even if the user stops early.
# Usage: quiz-score.sh <deck> right|wrong
DECK="$1"; RES="$2"
F="${WORKSPACE:-/sandbox/.openclaw/workspace}/flashcards/scores.md"
mkdir -p "$(dirname "$F")"; touch "$F"
TODAY=$(TZ="${BRIEF_TZ:-Asia/Kolkata}" date +%Y-%m-%d)
KEY="$TODAY | $DECK | "
LINE=$(grep -F "$KEY" "$F" | tail -1)
R=0; N=0
if [ -n "$LINE" ]; then S=${LINE##* | }; R=${S%/*}; N=${S#*/}; fi
N=$((N+1)); [ "$RES" = right ] && R=$((R+1))
grep -v -F "$KEY" "$F" > "$F.tmp"; cat "$F.tmp" > "$F"; rm -f "$F.tmp"
echo "$KEY$R/$N" >> "$F"
echo "Score so far: $R/$N"
