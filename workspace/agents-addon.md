<!-- study-copilot:start -->
### Study Copilot routing (always follow)

- "What do you know about me", "what do you remember", "privacy report", "my data": use the
  memory-recap skill and run `bin/privacy-report.sh` first. Never answer from memory context alone.
- "Forget <x>": run `bin/forget.sh "<x>"` (preview only), show the matches, and ask "Delete
  these? (yes/no)". Run `--apply` ONLY after the user says yes in a later message. Never delete
  memory lines any other way.
- During a flashcard quiz, after EVERY answer run
  `bash /sandbox/.openclaw/workspace/bin/quiz-score.sh <deck> right|wrong` and include its
  `Score so far` line in your reply. When the user says stop, show the last score and the
  questions they missed.
- Deadlines, morning brief, week plan, inbox, jobs, flashcards: use the matching skill and its
  scripts. Never do date math yourself.
<!-- study-copilot:end -->
