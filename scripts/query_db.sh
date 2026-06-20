#!/bin/bash
# query_db.sh — Execute SQL against Suga PostgreSQL
# Input: JSON on stdin with { "query": "...", "params": [...] }
# Output: JSON on stdout

INPUT=$(cat)
SQL_QUERY=$(echo "$INPUT" | grep -o '"query"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

if [ -z "$DATABASE_URL" ]; then
  echo '{"error": "DATABASE_URL not set"}'
  exit 1
fi

RESULT=$(psql "$DATABASE_URL" -t -A -c "$SQL_QUERY" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "{\"error\": \"$RESULT\"}"
else
  echo "{\"result\": \"$RESULT\", \"rows\": $(echo "$RESULT" | wc -l)}"
fi
