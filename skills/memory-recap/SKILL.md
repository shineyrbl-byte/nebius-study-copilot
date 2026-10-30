---
name: memory-recap
description: Privacy report of everything saved about the user. Use whenever the user says "privacy report", "what do you know about me", "what do you remember", "show my data", "forget <something>", or "delete what you know about <something>". ALWAYS run bin/privacy-report.sh first; never answer from memory context.
---
# Memory Recap (privacy report)

## Your reply MUST use exactly this template
WHAT I REMEMBER:
- <each fact from MEMORY.md, USER.md, and the daily notes, one short line each>
YOUR DATA: <one line with the counts from YOUR DATA FILES>
BACKGROUND COPIES: <the COPIES MADE BY BACKGROUND MEMORY line>
WHERE IT CAN GO: <the WHERE YOUR DATA CAN GO section in one or two lines>
Want me to forget anything? Say "forget <topic>".

## Required step (before replying)
Run this command and fill the template using ONLY its output:
bash /sandbox/.openclaw/workspace/bin/privacy-report.sh
Do not answer from what is already in your context, even if you think you know.

## Forgetting (two separate turns, never one)
Turn 1 is preview ONLY. You may not run --apply in the same turn as the request.
1. Preview first: bash /sandbox/.openclaw/workspace/bin/forget.sh "<topic>"
2. Reply: "Found <N> lines in <files>. Delete them? (yes/no)" and show up to 3 examples.
3. Only if the user says yes, run: bash /sandbox/.openclaw/workspace/bin/forget.sh "<topic>" --apply
4. Confirm what was deleted, and stop using that fact from now on. Tell the user they can say
   "undo forget" (run forget.sh --undo) or "erase for good" (run forget.sh --purge).
5. Never edit memory files by hand to forget something; only use forget.sh.

## Rules
- Never claim to remember something that is not in the report.
- Never run --apply without a yes from the user in this conversation.
- If the script says NOTHING_FOUND, say you have nothing saved about it.
- Use a short, specific topic (for example "November 15" or "internship"), not a whole sentence.
