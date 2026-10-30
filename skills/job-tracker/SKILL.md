---
name: job-tracker
description: Track internship and job applications. Use whenever the user pastes a job or internship posting, says "save this job", "track this application", "I applied to <company>", "my applications", or "job tracker".
---
# Job Tracker

## Saving a posting: your reply MUST use exactly this template
Company: <company>
Role: <role>
Apply by: <YYYY-MM-DD, or "not stated">
Location: <location, or "not stated">
Key requirements:
- <up to 5 short points>
Saved to: /sandbox/.openclaw/workspace/jobs.md
Add the apply-by date to your deadline tracker? (yes/no)

## Required steps
1. Get today's date by running `date +%Y-%m-%d`. Do not guess it.
2. Extract only what the posting says. Never invent dates, salaries, or requirements.
3. Append one line to /sandbox/.openclaw/workspace/jobs.md (create it if missing):
   YYYY-MM-DD | company | role | apply-by YYYY-MM-DD or none | saved | link or none | key requirements
   The first date is today. Every line has exactly seven fields separated by " | ".
4. Reply with the template above.

## If the user answers yes
Append to /sandbox/.openclaw/workspace/deadlines.md (the date is the APPLY-BY date, not today):
<apply-by YYYY-MM-DD> | job | apply: <company> <role> | open
Then reply: "Added: <that exact line>".

## Updating status
Status is one of: saved, applied, interview, offer, rejected.
When the user says they applied, got an interview, an offer, or a rejection, change that
line's status field. Never delete lines. If they applied, also mark the matching
"apply: <company>" deadline as done.

## Listing
When asked about applications, read jobs.md and show a short table grouped by status,
with apply-by dates. Flag apply-by dates in the next 7 days.
