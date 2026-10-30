#!/bin/bash
# Run INSIDE the sandbox once. Registers an OpenClaw cron job that writes the
# morning brief every day at 07:00 (Asia/Kolkata by default) using Nemotron Nano,
# even when nobody is chatting. Re-running it updates the same job.
# Optional: TELEGRAM_CHAT_ID=<id> to also send the brief to Telegram
# (needs the Telegram channel set up in NemoClaw).
TIME_CRON="${BRIEF_CRON:-0 7 * * *}"
TZ_NAME="${BRIEF_TZ:-Asia/Kolkata}"
EXTRA=()
if [ -n "$TELEGRAM_CHAT_ID" ]; then
  EXTRA=(--announce --channel telegram --to "$TELEGRAM_CHAT_ID")
else
  EXTRA=(--no-deliver)
fi
openclaw cron add \
  --name morning-brief-daily \
  --display-name "Daily morning brief (Nemotron Nano)" \
  --declaration-key study-copilot:morning-brief \
  --cron "$TIME_CRON" --tz "$TZ_NAME" --exact \
  --command "bash /sandbox/.openclaw/workspace/bin/daily-brief.sh" \
  --timeout-seconds 300 \
  "${EXTRA[@]}"
echo
echo "Check it:  openclaw cron list"
echo "Run now:   openclaw cron run <job id>"
