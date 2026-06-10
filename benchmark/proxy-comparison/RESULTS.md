# Proxy comparison results

- **Run**: `20260609T203510Z`
- **lic branch**: `feat/dynamic-httpd-routes` @ `e25c8b815`
- **Backend**: nginx static (GitLab sign_in assets, 18 paths)
- **TLS**: self-signed `gitlab.lilangverse.xyz`, curl `--resolve`

## Summary table

| Proxy | Workload | Success rate | p95 latency (s) | RSS MB (parallel 18) | RPS |
|-------|----------|--------------|-----------------|----------------------|-----|
| nginx-proxy | sequential_1p3mb | 100.0% (1/1) | 0.010 | 32.5 | 55.0 |
| nginx-proxy | parallel_18 | 100.0% (18/18) | 0.024 | 32.5 | 221.1 |
| nginx-proxy | parallel_6_same | 100.0% (6/6) | 0.013 | 32.5 | 112.6 |
| nginx-proxy | mix_small_large | 100.0% (2/2) | 0.007 | 32.5 | 44.4 |
| caddy-proxy | sequential_1p3mb | 100.0% (1/1) | 0.009 | 16.2 | 54.6 |
| caddy-proxy | parallel_18 | 100.0% (18/18) | 0.014 | 16.2 | 262.8 |
| caddy-proxy | parallel_6_same | 100.0% (6/6) | 0.013 | 16.2 | 116.0 |
| caddy-proxy | mix_small_large | 100.0% (2/2) | 0.007 | 16.2 | 46.4 |
| haproxy-proxy | sequential_1p3mb | 100.0% (1/1) | 0.008 | 22.2 | 61.7 |
| haproxy-proxy | parallel_18 | 100.0% (18/18) | 0.045 | 22.2 | 193.8 |
| haproxy-proxy | parallel_6_same | 100.0% (6/6) | 0.012 | 22.2 | 120.5 |
| haproxy-proxy | mix_small_large | 100.0% (2/2) | 0.007 | 22.2 | 46.7 |
| li-httpd | sequential_1p3mb | 100.0% (1/1) | 0.017 | 11.6 | 17.0 |
| li-httpd | parallel_18 | 0.0% (0/18) | 60.000 | 11.6 | 0.3 |
| li-httpd | parallel_6_same | 0.0% (0/6) | 60.000 | 11.6 | 0.1 |
| li-httpd | mix_small_large | 0.0% (0/2) | 0.003 | 11.6 | 55.9 |

## Concurrency models

- **li-httpd**: 2 worker processes, epoll event loop per worker, Li-owned proxy relay
- **nginx-proxy**: auto worker_processes, epoll per worker, async upstream→client buffers
- **caddy-proxy**: Go runtime, goroutine-per-connection, reverse_proxy flush
- **haproxy-proxy**: single process, event-driven (epoll/kqueue), connection-oriented HTTP mode

## Raw files

- `results.jsonl`
- `results.csv`
