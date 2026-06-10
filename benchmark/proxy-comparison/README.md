# Proxy comparison benchmark

Compare **li-httpd** against nginx, Caddy, and HAProxy under identical GitLab `sign_in` workloads.

## Quick run (WSL + Docker)

```bash
cd lic/benchmark/proxy-comparison
bash pull-images.sh          # once; avoids WSL credsStore pull failures
bash run-benchmark.sh
```

Results land in `results/<timestamp>/RESULTS.md` and `benchmark/RESULTS.md`.

## Workloads

| ID | Pattern |
|----|---------|
| `sequential_1p3mb` | Single `main.deadbeef.chunk.js` (1.3 MB) |
| `parallel_18` | All 18 sign_in CSS/JS assets concurrently |
| `parallel_6_same` | Six parallel fetches of the 1.3 MB chunk |
| `mix_small_large` | `utilities-deadbeef.css` (84 B) + `application-deadbeef.css` (835 KB) |

## li-httpd image

Uses local `proxy-repro-proxy:latest` when present (built from `lic` via `test/proxy-repro`). Otherwise builds `Dockerfile.li-httpd` from `feat/dynamic-httpd-routes`.

## Latest run

See [`../RESULTS.md`](../RESULTS.md) and [`ARCHITECTURE_LESSONS.md`](../ARCHITECTURE_LESSONS.md).
