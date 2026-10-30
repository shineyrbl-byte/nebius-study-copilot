---
name: study-planner
description: Build a day-by-day study plan for the next 7 days from the user's deadlines. Use whenever the user says "plan my week", "study plan", "weekly plan", or "how should I prepare for <exam/deadline>". Always run the planner script; never plan from memory.
---
# Study Planner

## Required step
Run this command and show its output:
bash /sandbox/.openclaw/workspace/bin/weekly-plan.sh

The script computes the dates and asks NVIDIA Nemotron 3 Ultra to split big deadlines
into small daily tasks. It saves the plan to /sandbox/.openclaw/workspace/plans/.

## Your reply
1. Show the plan exactly as the script printed it (keep the dates and times).
2. Add one line: "Saved to: <path from the script>".
3. Ask: "Want me to adjust anything, like fewer tasks on a busy day?"

## Rules
- Never invent deadlines or change dates. If the script says there are no open deadlines, say so and offer to add some.
- If the user asks for changes, edit the saved plan file and show the changed days only.
- If the script fails, say the planner is unavailable and offer the morning brief instead.
