# Ghost SuperComputer — Deployment Guide

## Prerequisites
- GitHub account
- Cloudflare account (free)
- Neon account (free)
- Supabase account (free)
- Suga.app account (free)
- Node.js 18+ (for local testing)

## Step 1: Fork the Repo
```bash
# Fork https://github.com/BrightBighead1/ghost-supercomputer to your account
# Clone locally
git clone https://github.com/YOUR_USERNAME/ghost-supercomputer.git
cd ghost-supercomputer
git checkout free-tier-architecture
```

## Step 2: Setup Cloudflare
1. Sign up at cloudflare.com (no CC required)
2. Add your domain (or use workers.dev subdomain)
3. Go to R2 → Create bucket: `ghost-storage`
4. Go to Vectorize → Create index: `ghost-agent-vectors` (dimensions: 384)
5. Go to Workers → Create worker: `ghost-api`
6. Copy `cloudflare/worker.js` into the worker
7. Go to Zero Trust → Networks → Tunnels → Create tunnel
8. Install tunnel connector on your Suga service (after Step 5)

## Step 3: Setup Neon
1. Sign up at neon.tech (no CC required)
2. Create project: `ghost-db`
3. Go to SQL Editor
4. Paste contents of `neon-schema.sql` and run
5. Copy connection string from Dashboard → Connection Details

## Step 4: Setup Supabase
1. Sign up at supabase.com (no CC required)
2. Create project: `ghost-auth`
3. Go to Authentication → Providers → Enable email
4. Go to Storage → Create bucket: `ghost-files`
5. Copy URL and anon key from Settings → API

## Step 5: Deploy to Suga
1. Sign up at suga.app (no CC required)
2. Connect your GitHub repo
3. Create new service from `docker-compose.yml`
4. Set environment variables (copy from `.env.example`)
5. Deploy — Suga builds and runs your containers

## Step 6: Configure GitAgent
```bash
# SSH into your Suga container or use Suga console
# Edit agent.yaml with your preferred model
# Test: curl http://localhost:3333/api/health
```

## Step 7: Setup Keep-Alive
1. Go to cron-job.org (free account)
2. Create job: `POST https://YOUR_SUPABASE_URL/rest/v1/` every 5 days
3. Create job: `GET https://YOUR_SUGA_URL/api/health` every 10 minutes

## Step 8: Verify
- [ ] GitAgent responds at `https://YOUR_DOMAIN/api/agent/`
- [ ] n8n editor accessible at `https://YOUR_DOMAIN/n8n/`
- [ ] PocketBase admin at `https://YOUR_DOMAIN/pb/`
- [ ] Neon database has tables
- [ ] Supabase auth works
- [ ] R2 file upload works
- [ ] cron-job.org pings succeed

## Troubleshooting

### Supabase project paused
- cron-job.org should prevent this
- Unpause manually in Supabase dashboard
- Check cron-job.org job history

### Neon database connection refused
- Check NEON_DATABASE_URL in .env
- Ensure SSL mode is required
- Verify IP allowlist (should be 0.0.0.0/0)

### Suga container won't start
- Check Suga build logs
- Verify all environment variables are set
- Ensure total memory stays under 1 GB

### Cloudflare Worker errors
- Check worker logs in Cloudflare dashboard
- Verify KV namespace ID in wrangler.toml
- Ensure R2 bucket exists and is accessible
