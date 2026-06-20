// Ghost SuperComputer — Cloudflare Worker
// Routes API requests to Suga.app backend
// Handles vector search via Vectorize, file serving via R2

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // Route: Vector search
      if (path === '/api/search') {
        return await handleVectorSearch(request, env, corsHeaders);
      }

      // Route: File upload to R2
      if (path === '/api/upload') {
        return await handleFileUpload(request, env, corsHeaders);
      }

      // Route: File download from R2
      if (path.startsWith('/api/files/')) {
        return await handleFileDownload(path, env, corsHeaders);
      }

      // Route: Agent API (proxy to Suga)
      if (path.startsWith('/api/agent/')) {
        return await proxyToSuga(request, env, corsHeaders);
      }

      // Route: Health check
      if (path === '/api/health') {
        return new Response(JSON.stringify({
          status: 'healthy',
          service: 'ghost-supercomputer',
          timestamp: new Date().toISOString(),
          version: '1.0.0'
        }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // Route: Usage stats
      if (path === '/api/usage') {
        return await handleUsageStats(env, corsHeaders);
      }

      // Default: 404
      return new Response(JSON.stringify({ error: 'Not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });

    } catch (err) {
      return new Response(JSON.stringify({ error: err.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }
};

// Vector search via Cloudflare Vectorize
async function handleVectorSearch(request, env, corsHeaders) {
  const { query, topK = 5 } = await request.json();

  // Generate embedding for query (using Workers AI)
  const embeddingResponse = await env.AI.run('@cf/baai/bge-small-en-v1.5', {
    text: query
  });

  const queryVector = embeddingResponse.data[0];

  // Search Vectorize
  const results = await env.VECTORIZE.query(queryVector, {
    topK: topK,
    namespace: 'ghost-agent'
  });

  return new Response(JSON.stringify({
    results: results.matches.map(m => ({
      id: m.id,
      score: m.score,
      metadata: m.metadata
    }))
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// File upload to R2
async function handleFileUpload(request, env, corsHeaders) {
  const formData = await request.formData();
  const file = formData.get('file');
  const key = formData.get('key') || `uploads/${Date.now()}-${file.name}`;

  await env.R2.put(key, file.stream(), {
    httpMetadata: { contentType: file.type }
  });

  return new Response(JSON.stringify({
    url: `${env.R2_PUBLIC_URL}/${key}`,
    key: key,
    size: file.size,
    type: file.type
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// File download from R2
async function handleFileDownload(path, env, corsHeaders) {
  const key = path.replace('/api/files/', '');
  const object = await env.R2.get(key);

  if (!object) {
    return new Response(JSON.stringify({ error: 'File not found' }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const headers = new Headers(corsHeaders);
  headers.set('Content-Type', object.httpMetadata.contentType || 'application/octet-stream');
  headers.set('Content-Length', object.size.toString());
  headers.set('Cache-Control', 'public, max-age=31536000');

  return new Response(object.body, { headers });
}

// Proxy requests to Suga.app backend
async function proxyToSuga(request, env, corsHeaders) {
  const targetUrl = new URL(request.url);
  targetUrl.hostname = env.SUGA_HOST;
  targetUrl.port = env.SUGA_PORT || '3333';
  targetUrl.pathname = targetUrl.pathname.replace('/api/agent', '');

  const proxyRequest = new Request(targetUrl.toString(), {
    method: request.method,
    headers: request.headers,
    body: request.body
  });

  const response = await fetch(proxyRequest);
  const newHeaders = new Headers(corsHeaders);

  response.headers.forEach((value, key) => {
    if (!key.startsWith('x-')) newHeaders.set(key, value);
  });

  return new Response(response.body, {
    status: response.status,
    headers: newHeaders
  });
}

// Usage statistics
async function handleUsageStats(env, corsHeaders) {
  // Check KV for daily usage counters
  const today = new Date().toISOString().split('T')[0];
  const usageKey = `usage:${today}`;

  const usage = await env.KV.get(usageKey, { type: 'json' }) || {
    api_requests: 0,
    llm_queries: 0,
    storage_bytes: 0
  };

  return new Response(JSON.stringify({
    date: today,
    usage: usage,
    limits: {
      api_requests: { used: usage.api_requests, limit: 100000, unit: 'per day' },
      llm_queries: { used: usage.llm_queries, limit: 100, unit: 'per day' },
      storage: { used: usage.storage_bytes, limit: 10737418240, unit: 'bytes (10GB)' }
    }
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}
