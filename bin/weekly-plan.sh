#!/bin/bash
# Turns open deadlines into a day-by-day plan for the next 7 days.
# Uses Nemotron 3 Ultra for the multi-step planning (falls back to Super).
# Saves to plans/week-of-YYYY-MM-DD.md and prints it.
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${PLANS_DIR:-/sandbox/.openclaw/workspace/plans}"
mkdir -p "$OUT_DIR"
DATA=$(bash "$DIR/plan-data.sh")
TODAY=$(echo "$DATA" | sed -n 's/^TODAY: //p')
if echo "$DATA" | grep -q NO_DEADLINES; then
  echo "No open deadlines, so there is nothing to plan. Add some deadlines first."; exit 0
fi
PROMPT='You are a study coach. Build a realistic 7-day plan from the data.
Rules:
- Use ONLY the dates listed under PLAN_DAYS and the deadlines under OPEN_DEADLINES. Never invent deadlines.
- Split big items (exams, projects, applications) into small concrete steps spread across days before the due date.
- Most urgent first. At most 3 tasks per day, each 25-90 minutes with a time estimate.
- Leave the due date itself light: final check and submit.
- Mention deadlines after the 7 days only if work should start this week.
Reply in exactly this format:
WEEK PLAN (<first day> to <last day>)
<YYYY-MM-DD Weekday>
- <task> (<minutes> min) -> <deadline it serves>
(one block per day, all 7 days)
BIGGEST RISK: <one sentence>'
PLAN=$(echo "$DATA" | bash "$DIR/nemotron.sh" ultra "$PROMPT") ||
  { echo "Planner model unavailable. Try again later."; exit 1; }
FILE="$OUT_DIR/week-of-$TODAY.md"
{ echo "# Week plan from $TODAY"; echo; echo "$PLAN"; } > "$FILE"
cat "$FILE"
echo
echo "Saved to: $FILE"
