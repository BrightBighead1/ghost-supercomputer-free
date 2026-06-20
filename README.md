# Ghost SuperComputer — Free Tier (Suga-Native)

A 24/7 AI agent running entirely on **Suga.app free tier**. No credit card. No student email. $0/month forever.

## Architecture

Everything runs inside Suga.app. No external databases, no external storage, no CDN.

| Layer | Service | Source |
|-------|---------|--------|
| AI Agent | GitAgent | Custom Docker service |
| Database | PostgreSQL | Suga template |
| Auth + Files | PocketBase | Suga template |
| Object Storage | MinIO | Suga template |
| Search | Meilisearch | Suga template |
| LLM Gateway | LiteLLM | Suga template |
| Automation | n8n | Suga template |
| Monitoring | Uptime Kuma | Suga template |
| Dashboards | Grafana | Suga template |

## Quick Start

### 1. Create Suga Account

Go to [suga.app/sign-up](https://suga.app/sign-up) — no credit card needed.

### 2. Create Suga Project

1. Click **New Project**
2. Connect your GitHub repo: `BrightBighead1/ghost-supercomputer-free`
3. Or paste: `https://github.com/BrightBighead1/ghost-supercomputer-free`

### 3. Add Suga Services (from templates)

In your Suga project, add these services from the templates:

| Order | Template | Name | Purpose |
|-------|----------|------|---------|
| 1 | PostgreSQL | `postgres` | Main database |
| 2 | PocketBase | `pocketbase` | Auth + file storage |
| 3 | MinIO | `minio` | S3-compatible object storage |
| 4 | Meilisearch | `meilisearch` | Full-text search |
| 5 | LiteLLM | `litellm` | Unified LLM API gateway |
| 6 | n8n | `n8n` | Workflow automation |
| 7 | Uptime Kuma | `uptime-kuma` | Service monitoring |
| 8 | Grafana | `grafana` | Dashboards |
| 9 | Custom Docker | `gitagent` | Our AI agent |

### 4. Configure Environment Variables

In Suga dashboard, set these env vars for the `gitagent` service:

```bash
# Database (from Suga PostgreSQL template)
DATABASE_URL=postgresql://user:pass@postgres:5432/ghost?sslmode=require

# PocketBase (from Suga PocketBase template)
POCKETBASE_URL=http://pocketbase:8090
POCKETBASE_ANON_KEY=your_key

# MinIO (from Suga MinIO template)
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=your_key
MINIO_SECRET_KEY=your_secret

# Meilisearch (from Suga Meilisearch template)
MEILI_URL=http://meilisearch:7700
MEILI_MASTER_KEY=your_key

# LiteLLM (from Suga LiteLLM template)
LITELLM_URL=http://litellm:4000

# LLM keys (configure in LiteLLM dashboard)
OPENAI_API_KEY=sk-xxx
ANTHROPIC_API_KEY=sk-ant-xxx
GITHUB_TOKEN=ghp_xxx
```

### 5. Deploy

Suga auto-deploys on git push. Just push to your repo:

```bash
git add -A
git commit -m "Initial deploy"
git push
```

### 6. Setup Database Schema

Go to Suga PostgreSQL → SQL Editor → paste `schema.sql` → Run.

### 7. Setup Keep-Alive

1. Go to [cron-job.org](https://cron-job.org)
2. Create job: `GET https://YOUR_SUGA_URL/api/health` every 10 minutes

## Services

Once deployed:

| Service | URL |
|---------|-----|
| Agent UI | `https://YOUR_SUGA_HOST/api/agent/` |
| n8n Editor | `https://YOUR_SUGA_HOST/n8n/` |
| PocketBase | `https://YOUR_SUGA_HOST/pb/` |
| MinIO Console | `https://YOUR_SUGA_HOST/minio/` |
| Meilisearch | `https://YOUR_SUGA_HOST/meilisearch/` |
| LiteLLM | `https://YOUR_SUGA_HOST/litellm/` |
| Uptime Kuma | `https://YOUR_SUGA_HOST/uptime-kuma/` |
| Grafana | `https://YOUR_SUGA_HOST/grafana/` |
| Health Check | `https://YOUR_SUGA_HOST/api/health` |

## Files

```
ghost-supercomputer-free/
├── docker-compose.yml      # GitAgent service definition
├── .env.example            # Environment template
├── schema.sql              # PostgreSQL schema
├── setup.ps1               # Interactive setup (Windows)
├── agent/
│   ├── Dockerfile          # GitAgent container
│   ├── agent.yaml          # Agent config
│   ├── SOUL.md             # Agent personality
│   ├── RULES.md            # Behavioral rules
│   ├── tools/              # Tool definitions (DB, storage, search, notify)
│   ├── skills/             # Skill files
│   └── memory/             # Persistent memory
└── scripts/
    ├── keep-alive.sh       # Keep-alive pings
    ├── query_db.sh         # PostgreSQL queries
    ├── upload_minio.sh     # MinIO file upload
    ├── search.sh           # Meilisearch search
    └── notify.sh           # n8n notifications
```

## Cost: $0/month forever

No credit card required. No trial period. No student email needed. Runs 24/7 even when your laptop is off.

## License

MIT
