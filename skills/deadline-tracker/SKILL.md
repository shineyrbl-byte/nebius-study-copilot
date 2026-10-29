---
name: deadline-tracker
description: Track the user's deadlines (study, job applications, personal) in a persistent file and report what is due soon.
---
# Deadline Tracker

Deadlines are stored in /sandbox/.openclaw/workspace/deadlines.md, one per line:
YYYY-MM-DD | category (study/job/personal) | title | status (open/done)

## Adding
When the user mentions a deadline, add a line to the file (create it if missing).
Always write the full date as YYYY-MM-DD. Confirm by quoting the line you saved.

## Listing
When asked what is due, read the file and show open items sorted by date, with
days remaining from today. Flag anything overdue or due within 3 days.

## Completing
When the user says something is finished, change its status to done. Never delete lines.

## Rules
- Get today's date from the system (run `date` if you have a shell tool). Do not guess it.
- Never invent deadlines. If the file is empty or missing, say so.

## Format example
2026-11-15 | study | project | open
Every line MUST have exactly four fields separated by " | ", including the final status field.
