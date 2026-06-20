#!/bin/bash
# upload_minio.sh — Upload file to Suga MinIO
# Input: JSON on stdin with { "file_path": "...", "key": "...", "content_type": "..." }
# Output: JSON on stdout

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
KEY=$(echo "$INPUT" | grep -o '"key"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
CONTENT_TYPE=$(echo "$INPUT" | grep -o '"content_type"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

CONTENT_TYPE=${CONTENT_TYPE:-"application/octet-stream"}

if [ -z "$MINIO_ENDPOINT" ] || [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ]; then
  echo '{"error": "MinIO credentials not set"}'
  exit 1
fi

# Install mc client if not present
if ! command -v mc &> /dev/null; then
  curl -sL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc
  chmod +x /usr/local/bin/mc
fi

mc alias set ghost-minio "$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api S3v4

# Create bucket if it doesn't exist
mc mb ghost-minio/ghost-storage 2>/dev/null || true

mc cp "$FILE_PATH" "ghost-minio/ghost-storage/$KEY" 2>&1

if [ $? -eq 0 ]; then
  echo "{\"url\": \"$MINIO_ENDPOINT/ghost-storage/$KEY\", \"key\": \"$KEY\"}"
else
  echo '{"error": "Upload failed"}'
fi
