# Next.js-style parallel chunk load through li-httpd TLS proxy

Simulates `/_next/static/chunks/*` parallel browser fetches behind the edge proxy.

## Run (from `lic/`)

```bash
docker compose -f test/nextjs-proxy/docker-compose.yml build
docker compose -f test/nextjs-proxy/docker-compose.yml up --abort-on-container-exit tester
```

Pass: all chunk `wc -c` sizes match `Content-Length` (18 parallel).
