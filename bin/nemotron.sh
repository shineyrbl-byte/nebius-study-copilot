#!/bin/bash
# Send stdin to a Nemotron model on Nebius Token Factory and print the reply.
# Usage: nemotron.sh <nano|super|ultra> "<system prompt>"  < input.txt
# Picks the right-sized model for the job: Nano for quick formatting,
# Super for everyday chat, Ultra for heavy planning. Falls back to Super on error.
set -o pipefail
SIZE="$1"; SYSTEM="$2"
case "$SIZE" in
  nano)  MODEL="${NANO_MODEL:-nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B}" ;;
  ultra) MODEL="${ULTRA_MODEL:-nvidia/Nemotron-3-Ultra-550b-a55b}" ;;
  *)     MODEL="${SUPER_MODEL:-nvidia/nemotron-3-super-120b-a12b}" ;;
esac
# Reasoning models spend tokens thinking first, so give the planner more room.
[ "$SIZE" = ultra ] && MAXTOK="${MAX_TOKENS:-8192}" || MAXTOK="${MAX_TOKENS:-2048}"
FALLBACK="${SUPER_MODEL:-nvidia/nemotron-3-super-120b-a12b}"

# Endpoint and key: env vars first (host / Nebius Serverless Job), else the
# sandbox's OpenClaw config. Inside OpenShell the key there is a placeholder
# that the gateway swaps for the real key, so the real key never enters the sandbox.
CONF=/sandbox/.openclaw/openclaw.json
BASE="${NEBIUS_BASE_URL:-}"; KEY="${NEBIUS_API_KEY:-}"
if [ -z "$KEY" ] && [ -f "$CONF" ]; then
  BASE="${BASE:-$(jq -r '.models.providers.inference.baseUrl' "$CONF")}"
  KEY=$(jq -r '.models.providers.inference.apiKey' "$CONF")
fi
BASE="${BASE:-https://api.tokenfactory.us-central1.nebius.com/v1}"
[ -z "$KEY" ] && { echo "nemotron.sh: no API key (set NEBIUS_API_KEY)" >&2; exit 2; }

INPUT=$(cat)
call() {
  jq -n --arg m "$1" --arg s "$SYSTEM" --arg u "$INPUT" --argjson t "$MAXTOK" \
    '{model:$m, temperature:0.3, max_tokens:$t,
      messages:[{role:"system",content:$s},{role:"user",content:$u}]}' |
  curl -sS -m 300 "${BASE%/}/chat/completions" \
    -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d @- |
  jq -er '.choices[0].message.content // empty' |
  perl -0pe 's/<think>.*?<\/think>\s*//s; s/\A\s+//'
}
OUT=$(call "$MODEL") || OUT=""
if [ -z "$(echo "$OUT" | tr -d '[:space:]')" ] && [ "$MODEL" != "$FALLBACK" ]; then
  echo "nemotron.sh: $MODEL failed, falling back to $FALLBACK" >&2
  MODEL="$FALLBACK"; OUT=$(call "$MODEL") || OUT=""
fi
[ -z "$(echo "$OUT" | tr -d '[:space:]')" ] && { echo "nemotron.sh: no reply from $MODEL" >&2; exit 1; }
echo "$OUT"
echo "MODEL_USED: $MODEL" >&2
