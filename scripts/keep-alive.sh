#!/bin/bash
# keep-alive.sh — Prevent Supabase free tier from pausing
# Run via cron-job.org every 5 days
# Pings both Supabase and Suga endpoints

SUPABASE_URL="${SUPABASE_URL:-}"
SUGA_URL="${SUGA_URL:-}"

echo "[$(date -u)] Ghost keep-alive ping..."

# Ping Supabase (prevents 1-week inactivity pause)
if [ -n "$SUPABASE_URL" ]; then
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SUPABASE_URL/rest/v1/" \
    -H "apikey: ${SUPABASE_ANON_KEY:-}" 2>&1)
  echo "Supabase: HTTP $RESPONSE"
fi

# Ping Suga (keeps container warm)
if [ -n "$SUGA_URL" ]; then
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$SUGA_URL/api/health" 2>&1)
  echo "Suga: HTTP $RESPONSE"
fi

# Update usage counter in Neon
if [ -n "$NEON_DATABASE_URL" ]; then
  psql "$NEON_DATABASE_URL" -c "
    INSERT INTO usage_daily (date, api_requests)
    VALUES (CURRENT_DATE, 1)
    ON CONFLICT (date) DO UPDATE SET api_requests = usage_daily.api_requests + 1;
  " 2>/dev/null
  echo "Usage counter updated"
fi

echo "[$(date -u)] Keep-alive complete"
