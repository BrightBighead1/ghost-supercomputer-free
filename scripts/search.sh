#!/bin/bash
# search.sh — Search via Suga Meilisearch
# Input: JSON on stdin with { "query": "...", "index": "...", "limit": N }
# Output: JSON on stdout

INPUT=$(cat)
QUERY=$(echo "$INPUT" | grep -o '"query"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
INDEX=$(echo "$INPUT" | grep -o '"index"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
LIMIT=$(echo "$INPUT" | grep -o '"limit"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*')

INDEX=${INDEX:-"ghost-docs"}
LIMIT=${LIMIT:-10}

if [ -z "$MEILI_URL" ]; then
  echo '{"error": "MEILI_URL not set"}'
  exit 1
fi

HEADERS=""
if [ -n "$MEILI_API_KEY" ]; then
  HEADERS="-H \"X-Meili-API-Key: $MEILI_API_KEY\""
fi

RESULT=$(curl -s -X POST "$MEILI_URL/indexes/$INDEX/search" \
  -H "Content-Type: application/json" \
  -H "X-Meili-API-Key: ${MEILI_API_KEY:-}" \
  -d "{\"q\": \"$QUERY\", \"limit\": $LIMIT}" 2>&1)

echo "$RESULT"
