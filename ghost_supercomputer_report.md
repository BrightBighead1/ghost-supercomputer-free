# Ghost SuperComputer — Final Architecture Report

## Executive Summary

The Ghost SuperComputer is a free, always-on AI agent platform built entirely on free-tier cloud services. No credit card, no student email, no paid infrastructure. The system runs 24/7 using 11 tools that provide compute, database, storage, authentication, vector search, workflow automation, and AI inference — all at $0/month.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CLOUDFLARE EDGE                           │
│  DNS │ Tunnel │ CDN │ R2 (10GB) │ Vectorize │ Workers       │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  SUGA.APP (Always-On)                        │
│  0.5 vCPU │ 1 GB RAM │ 5 GB Storage │ No sleeping           │
│                                                           │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ │
│  │  Caddy    │ │  GitAgent │ │    n8n    │ │ PocketBase│ │
│  │  (proxy)  │ │  (agent)  │ │  (flows)  │ │   (auth)  │ │
│  └───────────┘ └───────────┘ └───────────┘ └───────────┘ │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│      NEON       │ │    SUPABASE     │ │     GITHUB      │
│   PostgreSQL    │ │ Auth + Storage  │ │  Code + CI/CD   │
│   0.5 GB free   │ │ 50K MAUs free   │ │  Unlimited      │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## Tool Inventory (11 Tools)

| # | Tool | Role | Free Limit | Always-On |
|---|------|------|------------|-----------|
| 1 | **GitHub** | Code hosting + CI/CD | Unlimited repos | ✅ |
| 2 | **Cloudflare** | DNS + Tunnel + CDN + R2 + Vectorize + Workers | 10GB R2, 100K req/day | ✅ |
| 3 | **Neon** | PostgreSQL database | 0.5 GB, 100 CU-hrs/mo | ✅ |
| 4 | **Supabase** | Auth + Storage + Edge Functions | 50K MAUs, 1 GB files | ⚠️ Pauses 1wk idle |
| 5 | **Suga.app** | Always-on compute | 0.5 vCPU, 1 GB RAM, 5 GB | ✅ |
| 6 | **GitAgent** | AI agent framework | MIT, unlimited | ✅ |
| 7 | **n8n** | Workflow automation | Self-hosted, unlimited | ✅ |
| 8 | **PocketBase** | Backup DB + quick auth | Self-hosted, unlimited | ✅ |
| 9 | **cron-job.org** | Keep-alive pings | Unlimited scheduled HTTP | ✅ |
| 10 | **Caddy** | Reverse proxy + HTTPS | Self-hosted, unlimited | ✅ |
| 11 | **Netdata** | Monitoring (optional) | Self-hosted, unlimited | ✅ |

## Service Mapping: Docker Stack → Free Stack

| Original Service | Replaced By | Savings |
|-----------------|-------------|---------|
| Caddy (VPS) | Caddy (in Suga container) | No VPS needed |
| Floci (S3) | Cloudflare R2 | 10GB free, no server |
| PocketBase | PocketBase (in container) | Still runs |
| Qdrant | Cloudflare Vectorize | Managed, no container |
| n8n | n8n (in container) | Still runs, fewer workflows |
| Netdata | Cloudflare Analytics | Lighter option |
| InsForge Postgres | Neon | Managed, 0.5GB free |
| InsForge PostgREST | Supabase Edge Functions | 500K invocations/mo |
| InsForge Deno | Cloudflare Workers | 100K req/day |
| InsForge (full) | Supabase | Replaces entire platform |
| Agent Worker | GitAgent | Better: git-native memory |
| Obscura | Dropped | Too heavy for 1GB RAM |
| Steel Browser | Dropped | Too heavy for 1GB RAM |
| Stealth Agent | Dropped | Too heavy for 1GB RAM |
| Dify (5 services) | GitAgent + n8n | Simpler, lighter |

## Resource Budget

| Resource | Available | Used | Headroom |
|----------|-----------|------|----------|
| **Compute** | 0.5 vCPU, 1 GB RAM | ~768 MB (4 containers) | 256 MB |
| **Database** | 0.5 GB (Neon) | ~200 MB estimated | 300 MB |
| **File Storage** | 1 GB (Supabase) + 10 GB (R2) | ~500 MB estimated | 10.5 GB |
| **Vector Search** | ~6,500 vectors (768-dim) | ~1,000 vectors | 5,500 |
| **API Requests** | 100K/day (Workers) | ~10K estimated | 90K |
| **LLM Queries** | ~50-100/day | ~30 estimated | 70 |
| **Auth Users** | 50,000 MAUs | Unlimited for personal use | 50K |

## What You Lose vs Full Docker Stack

| Feature | Full Stack | Free Stack | Impact |
|---------|-----------|------------|--------|
| Database size | Unlimited | 0.5 GB | Major reduction |
| Vector search | Millions of vectors | ~6,500 vectors | 99% less |
| Monitoring | Real-time host metrics | Request logs only | No CPU/memory metrics |
| Browser automation | Full Chrome | Not available | Dropped |
| Dify AI platform | Full platform | Not available | Replaced by GitAgent |
| Multiple containers | 24 containers | 4 containers | Consolidated |

## Cost Analysis

| Item | Cost |
|------|------|
| Suga.app | $0/month |
| Neon | $0/month |
| Supabase | $0/month |
| Cloudflare | $0/month |
| GitHub | $0/month |
| cron-job.org | $0/month |
| **TOTAL** | **$0/month forever** |

## Risk Mitigation

| Risk | Mitigation | Frequency |
|------|-----------|-----------|
| Supabase pauses after 1 week | cron-job.org pings every 5 days | Automated |
| Neon runs out of CU-hours | Use 0.25 CU, monitor weekly | Weekly check |
| Suga storage fills up | Use R2 for files, keep under 3GB | Monthly check |
| Cloudflare 100K req/day exceeded | Route heavy traffic through Suga directly | Monitor daily |
| Service changes free tier | Export scripts ready for all data | One-time setup |

## Deployment Time

| Step | Task | Time |
|------|------|------|
| 1 | GitHub repo setup | 5 min |
| 2 | Cloudflare account + DNS | 15 min |
| 3 | Neon database + schema | 10 min |
| 4 | Supabase project + auth | 10 min |
| 5 | Suga.app deploy | 10 min |
| 6 | GitAgent configuration | 15 min |
| 7 | cron-job.org setup | 5 min |
| 8 | Verification + testing | 10 min |
| **Total** | | **~75 min** |

## Files Generated

| File | Purpose |
|------|---------|
| `docker-compose.yml` | 4-service stack for Suga.app |
| `Caddyfile` | Reverse proxy configuration |
| `agent/agent.yaml` | GitAgent configuration |
| `agent/SOUL.md` | Agent personality |
| `agent/RULES.md` | Behavioral rules |
| `agent/Dockerfile` | GitAgent container build |
| `agent/tools/*.yaml` | 4 custom tool definitions |
| `scripts/*.sh` | 4 operational scripts |
| `neon-schema.sql` | Database schema (7 tables) |
| `cloudflare/worker.js` | Edge API router |
| `cloudflare/wrangler.toml` | Cloudflare config |
| `.env.example` | Environment template |
| `deploy.md` | Step-by-step deployment guide |
