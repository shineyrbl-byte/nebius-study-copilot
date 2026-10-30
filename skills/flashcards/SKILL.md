---
name: flashcards
description: Turn notes into flashcards and quiz the user. Use whenever the user says "make flashcards", "flashcards from <file>", "quiz me", "test me on <topic>", or "my flashcards".
---
# Flashcards

## After EVERY quiz answer (required)
Run: bash /sandbox/.openclaw/workspace/bin/quiz-score.sh <deck> right|wrong
Then reply with exactly:
Correct!  (or)  Not quite: <right answer>
<the "Score so far" line from the script>
Next: <next question>
When the user says stop, or all cards are done, reply with the last "Score so far" and
"Review these: <questions answered wrong, or none>". The score is already saved.

Decks live in /sandbox/.openclaw/workspace/flashcards/<deck-name>.md
Scores live in /sandbox/.openclaw/workspace/flashcards/scores.md

## Making a deck
1. Read the source file from /sandbox/.openclaw/workspace/inbox/ (or the summaries/ folder if the user names a digest). Never read other folders.
2. Write 5 to 12 cards, using only facts from that file. One card per line:
   Q: <short question> | A: <short answer>
3. Save them to flashcards/<source file name without extension>.md (create the folder if needed).
4. Reply with exactly:
   Made <N> flashcards from <file>.
   Saved to: <real path>
   Say "quiz me" to start.

## Quizzing (one card at a time)
1. If several decks exist and the user did not name one, list them and ask which.
2. Ask ONE question, then stop and wait for the answer. Do not show the answer first.
3. After each answer, follow "After EVERY quiz answer" at the top.

## Rules
- Never invent facts that are not in the source file.
- Accept answers that mean the same thing, even with different wording.
