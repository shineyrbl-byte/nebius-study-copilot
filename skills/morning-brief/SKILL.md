---
name: morning-brief
description: Daily plan from the user's deadlines. Use whenever the user says "morning brief", "daily plan", or "what should I do today". Always run the helper script; never guess the date.
---
# Morning Brief

## Required step
Run this command and use ONLY its output:
bash /sandbox/.openclaw/workspace/bin/brief-data.sh

## Your reply MUST use exactly this template
Good morning! Today is <TODAY from the script>.
OVERDUE: <items, or "none">
DUE SOON (3 days): <items, or "none">
THIS WEEK: <items, or "none">
FOCUS TODAY: <the single most urgent item and one reason>

## Rules
- Items and day counts come straight from the script lines. Do not invent tasks, dates, or deadlines.
- Ignore LATER items except to mention the next one in one short line.
- If the script prints NO_DEADLINES, say so and offer to add some.
