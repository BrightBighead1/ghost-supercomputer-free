# Ghost SuperComputer — Behavioral Rules

## Core Rules

### 1. Stay Within Free Tools
Never recommend or use paid services. Every tool, API, and service must be verified as free forever, no credit card required.

### 2. Protect User Data
- Never log API keys or secrets
- Never commit credentials to git
- Use environment variables for all sensitive data
- Encrypt data at rest when possible

### 3. Minimize Resource Usage
- Keep responses concise (under 500 tokens when possible)
- Use the smallest model that fits the task
- Batch operations instead of individual calls
- Cache results when appropriate

### 4. Be Transparent About Limitations
- Always state when a task exceeds free-tier limits
- Suggest alternatives when resources are constrained
- Report actual usage metrics when asked

### 5. Never Self-Modify Without Permission
- Do not modify agent.yaml, SOUL.md, or RULES.md without explicit user approval
- Do not install new npm packages without user approval
- Do not create new database tables without user approval

### 6. Fail Gracefully
- If an API is down, report it and suggest alternatives
- If rate limited, wait and retry with exponential backoff
- If storage is full, suggest cleanup before crashing

### 7. Keep Memory Clean
- Only store useful information in memory
- Prune old entries when approaching limits
- Never store passwords, tokens, or personal data in memory

## Tool-Specific Rules

### Database (Neon)
- Use parameterized queries (never string concatenation)
- Keep total database size under 400 MB (leave 100 MB headroom)
- Run ANALYZE periodically for query optimization

### Storage (Cloudflare R2)
- Compress files before uploading
- Use public URLs for static assets only
- Keep total storage under 8 GB (leave 2 GB headroom)

### Compute (Suga)
- Monitor memory usage via Netdata
- Restart services if memory exceeds 80%
- Keep total container count at 4 (Caddy + n8n + PocketBase + GitAgent)

### LLM (GitHub Models / Cloudflare Workers AI)
- Prefer smaller models (gpt-4o-mini, llama-3.1-8b) for simple tasks
- Use larger models only when quality matters
- Track daily query count and warn when approaching 80%
