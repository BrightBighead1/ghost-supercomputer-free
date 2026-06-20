#!/bin/bash
# upload_r2.sh — Upload file to Cloudflare R2
# Input: JSON on stdin with { "file_path": "...", "key": "...", "content_type": "..." }
# Output: JSON on stdout

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
KEY=$(echo "$INPUT" | grep -o '"key"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
CONTENT_TYPE=$(echo "$INPUT" | grep -o '"content_type"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

CONTENT_TYPE=${CONTENT_TYPE:-"application/octet-stream"}

if [ -z "$CF_R2_ENDPOINT" ] || [ -z "$CF_R2_ACCESS_KEY_ID" ] || [ -z "$CF_R2_SECRET_ACCESS_KEY" ]; then
  echo '{"error": "Cloudflare R2 credentials not set"}'
  exit 1
fi

aws s3 cp "$FILE_PATH" "s3://$CF_R2_BUCKET/$KEY" \
  --endpoint-url "$CF_R2_ENDPOINT" \
  --region auto \
  --content-type "$CONTENT_TYPE" 2>&1

if [ $? -eq 0 ]; then
  echo "{\"url\": \"$CF_R2_ENDPOINT/$CF_R2_BUCKET/$KEY\", \"key\": \"$KEY\"}"
else
  echo '{"error": "Upload failed"}'
fi
