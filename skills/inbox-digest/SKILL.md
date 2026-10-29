---
name: inbox-digest
description: Process files in the user's inbox folder (/sandbox/.openclaw/workspace/inbox/). Use whenever the user says "process my inbox", "inbox digest", or mentions a file they added to the inbox. Do not use any other summarizing tool for these files.
---
# Inbox Digest

Only read files inside /sandbox/.openclaw/workspace/inbox/. Never read other folders.

## Your reply MUST use exactly this template
Overview: <one sentence>
Key points:
- <point>
ACTION ITEMS:
- YYYY-MM-DD | <what must be done>
Saved to: <real path of the file you wrote>
Add these dates to your deadline tracker? (yes/no)

## Required steps
1. Read the file from the inbox.
2. Write the same digest to /sandbox/.openclaw/workspace/summaries/<filename>-digest.md using a tool.
3. Reply using the template. Only use details found in the file; never invent dates.

## If the user answers yes
Append each date to /sandbox/.openclaw/workspace/deadlines.md as:
YYYY-MM-DD | study | <title> | open
