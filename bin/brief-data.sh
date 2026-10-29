#!/bin/bash
# Computes today's date (India time) and days remaining for each open deadline,
# so the model never has to do date math.
TODAY=$(TZ=Asia/Kolkata date +%Y-%m-%d)
echo "TODAY: $TODAY"
F=/sandbox/.openclaw/workspace/deadlines.md
if [ ! -s "$F" ]; then echo "NO_DEADLINES"; exit 0; fi
today_s=$(date -d "$TODAY" +%s)
sort "$F" | while IFS='|' read -r d kind title status; do
  d=$(echo "$d" | xargs); kind=$(echo "$kind" | xargs)
  title=$(echo "$title" | xargs); status=$(echo "$status" | xargs)
  [ -z "$d" ] && continue
  [ "$status" = "done" ] && continue
  due_s=$(date -d "$d" +%s) || continue
  days=$(( (due_s - today_s) / 86400 ))
  if [ $days -lt 0 ]; then b=OVERDUE
  elif [ $days -le 3 ]; then b=DUE_SOON
  elif [ $days -le 7 ]; then b=THIS_WEEK
  else b=LATER; fi
  echo "$b | $d | $days days | $kind | $title"
done
