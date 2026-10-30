#!/bin/bash
# Entry point for the Nebius Serverless Job.
# Needs: NEBIUS_API_KEY (pass as a secret), a deadlines file at $DEADLINES_FILE.
# JOB_TASK = brief | plan | all. Output goes to the job logs.
set -u
if [ ! -s "$DEADLINES_FILE" ]; then
  echo "No deadlines file at $DEADLINES_FILE. Pass one with --inject-file." >&2
  exit 1
fi
echo "Study Copilot job: task=$JOB_TASK, $(grep -c . "$DEADLINES_FILE") deadline lines"
case "$JOB_TASK" in
  brief) bash /app/bin/daily-brief.sh ;;
  plan)  bash /app/bin/weekly-plan.sh ;;
  *)     bash /app/bin/daily-brief.sh; echo; echo "----"; echo; bash /app/bin/weekly-plan.sh ;;
esac
