# Ghost SuperComputer — Free Tier

A 24/7 AI agent running on **11 free tools**. No credit card. No student email. $0/month forever.

## Architecture

| Layer | Service | Free Limit |
|-------|---------|------------|
| Compute | Suga.app | 0.5 vCPU, 1 GB RAM, always-on |
| Database | Neon PostgreSQL | 0.5 GB storage, 100 CU-hrs/month |
| Auth + Storage | Supabase | 500 MB DB, 50K MAUs, 1 GB files |
| CDN | Cloudflare | Unlimited bandwidth |
| Object Storage | Cloudflare R2 | 10 GB |
| Vector Search | Cloudflare Vectorize | 5M reads, 1M writes/month |
| Edge Compute | Cloudflare Workers | 100K req/day |
| AI Agent | GitAgent | MIT license, git-native memory |
| Automation | n8n | Self-hosted, unlimited |
| Quick DB | PocketBase | Embedded, unlimited |
| Reverse Proxy | Caddy | Auto HTTPS, unlimited |

## Quick Start

### 1. Create Free Accounts

| Service | URL | What to Get |
|---------|-----|-------------|
| Cloudflare | cloudflare.com/sign-up | API Token, Zone ID, Account ID |
| Neon | neon.tech/signin | Connection string |
| Supabase | supabase.com/sign-in | Project URL, anon key, service key |
| Suga.app | suga.app/sign-up | Service URL |
| cron-job.org | cron-job.org | Keep-alive pings |

### 2. Fork & Clone

```bash
# Fork https://github.com/BrightBighead1/ghost-supercomputer-free
git clone https://github.com/YOUR_USERNAME/ghost-supercomputer-free.git
cd ghost-supercomputer-free
```

### 3. Configure

```bash
cp .env.example .env
# Edit .env with your values from step 1
```

### 4. Deploy Neon Schema

Go to Neon SQL Editor → paste `neon-schema.sql` → Run.

### 5. Deploy to Suga

1. Connect your GitHub repo to Suga.app
2. Set docker-compose path: `docker-compose.yml`
3. Add all env vars from `.env`
4. Deploy

### 6. Deploy Cloudflare Worker

```bash
cd cloudflare
npx wrangler deploy
# Set secrets:
npx wrangler secret put SUGA_HOST
npx wrangler secret put R2_PUBLIC_URL
```

### 7. Setup Keep-Alive

1. Go to cron-job.org
2. Create job: `GET https://YOUR_SUGA_URL/api/health` every 10 minutes
3. Create job: `POST https://YOUR_SUPABASE_URL/rest/v1/` every 5 days

## Services

Once deployed, your services are at:

| Service | URL |
|---------|-----|
| Agent UI | `https://YOUR_DOMAIN/api/agent/` |
| n8n Editor | `https://YOUR_DOMAIN/n8n/` |
| PocketBase | `https://YOUR_DOMAIN/pb/` |
| Health Check | `https://YOUR_DOMAIN/api/health` |

## Files

```
ghost-supercomputer-free/
├── docker-compose.yml      # 4 services (Caddy, n8n, PocketBase, GitAgent)
├── Caddyfile               # Reverse proxy config
├── .env.example            # Environment template
├── neon-schema.sql         # Database schema
├── agent/
│   ├── Dockerfile          # GitAgent container
│   ├── agent.yaml          # Agent config
│   ├── SOUL.md             # Agent personality
│   ├── RULES.md            # Behavioral rules
│   ├── tools/              # Tool definitions
│   ├── skills/             # Skill files
│   └── memory/             # Persistent memory
├── cloudflare/
│   ├── worker.js           # Edge API + R2 + Vectorize
│   └── wrangler.toml       # Cloudflare config
├── scripts/
│   ├── keep-alive.sh       # Supabase keep-alive
│   ├── query_db.sh         # Neon DB queries
│   ├── upload_r2.sh        # R2 file upload
│   ├── search.sh           # File search
│   └── notify.sh           # n8n notifications
└── setup.ps1               # Interactive setup (Windows)
```

## Resource Limits

| Resource | Limit | Current |
|----------|-------|---------|
| CPU | 0.5 vCPU | Suga.app |
| RAM | 1 GB | Suga.app |
| Database | 0.5 GB | Neon |
| Files | 1 GB | Supabase |
| Object Storage | 10 GB | Cloudflare R2 |
| Vectors | ~6K vectors | Cloudflare Vectorize |
| API Requests | 100K/day | Cloudflare Workers |
| LLM Queries | ~50-100/day | GitHub Models / Cloudflare AI |

## Cost: $0/month forever

No credit card required. No trial period. No student email needed. Runs 24/7 even when your laptop is off.

## License

MIT
