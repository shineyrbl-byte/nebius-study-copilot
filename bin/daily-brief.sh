#!/bin/bash
# Builds today's morning brief without a chat: date math in brief-data.sh,
# formatting by Nemotron Nano (fast and cheap). Saves to briefs/YYYY-MM-DD.md.
# Run on a schedule by OpenClaw cron (see bin/schedule-brief.sh) or as a
# Nebius Serverless Job (see serverless/).
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${BRIEFS_DIR:-/sandbox/.openclaw/workspace/briefs}"
mkdir -p "$OUT_DIR"
DATA=$(bash "$DIR/brief-data.sh")
TODAY=$(echo "$DATA" | sed -n 's/^TODAY: //p')
PROMPT='You format a student'"'"'s morning brief. Use ONLY the data given. Never invent tasks or dates.
Each data line is: BUCKET | date | days left | category | title.
Reply in exactly this format, nothing else:
Good morning! Today is <TODAY>.
OVERDUE: <items or "none">
DUE SOON (3 days): <items or "none">
THIS WEEK: <items or "none">
NEXT UP LATER: <the first LATER item in one short line, or "none">
FOCUS TODAY: <the single most urgent item and one short reason>
If the data says NO_DEADLINES, say there are no deadlines and suggest adding some.'
BRIEF=$(echo "$DATA" | bash "$DIR/nemotron.sh" nano "$PROMPT") ||
  BRIEF=$(printf 'Model unavailable, raw data:\n%s\n' "$DATA")
FILE="$OUT_DIR/$TODAY.md"
{ echo "# Morning brief $TODAY"; echo; echo "$BRIEF"; } > "$FILE"
cat "$FILE"
echo
echo "Saved to: $FILE"
