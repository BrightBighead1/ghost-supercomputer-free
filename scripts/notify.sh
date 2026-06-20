#!/bin/bash
# notify.sh — Send notification via Suga n8n webhook
# Input: JSON on stdin with { "message": "...", "level": "...", "channel": "..." }
# Output: JSON on stdout

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
LEVEL=$(echo "$INPUT" | grep -o '"level"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
CHANNEL=$(echo "$INPUT" | grep -o '"channel"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

LEVEL=${LEVEL:-"info"}
CHANNEL=${CHANNEL:-"webhook"}

N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL:-"http://n8n:5678/webhook/ghost-notify"}

PAYLOAD=$(cat <<EOF
{
  "message": "$MESSAGE",
  "level": "$LEVEL",
  "channel": "$CHANNEL",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "ghost-supercomputer"
}
EOF
)

RESULT=$(curl -s -X POST "$N8N_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" 2>&1)

echo "{\"sent\": true, \"channel\": \"$CHANNEL\", \"response\": \"$RESULT\"}"
