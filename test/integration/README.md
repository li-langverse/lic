# Real website and integration tests

Docker-based integration layers for li-httpd TLS proxy relay.

## Layers

| Directory | Layer | Description |
|-----------|-------|-------------|
| `real-sites/` | 2 | Static site with 19 CSS/JS/font assets, parallel wc -c gate |
| `../nextjs-proxy/` | 3 | Next.js `_next/static/*` chunk parallel loads |
| `../gitlab-proxy/` | 4 | GitLab sign_in HTML + 18 asset parallel gate |
| `../proxy-repro/` | 5 | Two-backend LB e2e (`round_robin`, `least_conn`, `ip_hash`) |

Run via `sh test/proxy/run-proxy-tests.sh --real-site` (etc.) from `lic/`.

Layer 6 (live k3s cluster) lives in `homelab-k3s/` — `npm test`.
