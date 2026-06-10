# Proxy comparison results

- **Run**: `20260609T201005Z`
- **lic branch**: `feat/dynamic-httpd-routes` @ `def403132`
- **Backend**: nginx static (GitLab sign_in assets, 18 paths)
- **TLS**: self-signed `gitlab.lilangverse.xyz`, curl `--resolve`

## Summary table

| Proxy | Workload | Success rate | p95 latency (s) | RSS MB (parallel 18) | RPS |
|-------|----------|--------------|-----------------|----------------------|-----|
| nginx-proxy | sequential_1p3mb | 100.0% (1/1) | 0.010 | 0.0 | 55.9 |
| nginx-proxy | parallel_18 | 100.0% (18/18) | 0.023 | 0.0 | 235.6 |
| nginx-proxy | parallel_6_same | 100.0% (6/6) | 0.013 | 0.0 | 118.8 |
| nginx-proxy | mix_small_large | 100.0% (2/2) | 0.007 | 0.0 | 48.8 |

## Concurrency models

- **li-httpd**: 2 worker processes, epoll event loop per worker, Li-owned proxy relay
- **nginx-proxy**: auto worker_processes, epoll per worker, async upstream→client buffers
- **caddy-proxy**: Go runtime, goroutine-per-connection, reverse_proxy flush
- **haproxy-proxy**: single process, event-driven (epoll/kqueue), connection-oriented HTTP mode

## Raw files

- `results.jsonl`
- `results.csv`
