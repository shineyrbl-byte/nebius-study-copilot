#!/bin/bash
# Facts for the study planner: the next 7 calendar days (with weekday) and every
# open deadline with days left. Computed here so the model never does date math.
DIR="$(cd "$(dirname "$0")" && pwd)"
TODAY=$(TZ="${BRIEF_TZ:-Asia/Kolkata}" date +%Y-%m-%d)
echo "TODAY: $TODAY"
echo "PLAN_DAYS:"
for i in 0 1 2 3 4 5 6; do echo "  $(date -d "$TODAY +$i day" '+%Y-%m-%d %A')"; done
echo "OPEN_DEADLINES:"
bash "$DIR/brief-data.sh" | grep -v '^TODAY:' | sed 's/^/  /'
