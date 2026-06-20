#!/bin/bash
# search.sh — Search project files
# Input: JSON on stdin with { "query": "...", "path": "...", "limit": N }
# Output: JSON on stdout

INPUT=$(cat)
QUERY=$(echo "$INPUT" | grep -o '"query"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
PATH_DIR=$(echo "$INPUT" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
LIMIT=$(echo "$INPUT" | grep -o '"limit"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*')

PATH_DIR=${PATH_DIR:-"/app"}
LIMIT=${LIMIT:-10}

RESULTS=$(grep -rl "$QUERY" "$PATH_DIR" 2>/dev/null | head -n "$LIMIT")
COUNT=$(echo "$RESULTS" | grep -c .)

echo "{\"results\": $(echo "$RESULTS" | jq -R -s 'split("\n") | map(select(length > 0))'), \"count\": $COUNT}"
