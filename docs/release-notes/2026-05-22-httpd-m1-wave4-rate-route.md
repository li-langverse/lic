# M1 wave 4 — rate limit 429 + runtime route table

## Summary

`li-httpd` loads desugared `route=` rows and global `rate_limit_*` from flattened runtime config; excess requests get **HTTP 429** with `Retry-After`. `flatten-httpd-config.py` uses `httpd_config` desugar; `explain-httpd-config.py` prints canonical routes.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_rate_limit_allow`, `path_proxy_match`, `httpd_load_runtime_config_i`); `scripts/flatten-httpd-config.py`; `packages/li-httpd/examples/rate_limit.toml`.
2. **Run:** `LI_REPO_ROOT=$PWD ./scripts/build.sh && lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; `./scripts/test-rate-limit-429.sh`.
3. **Then:** add `rate_limit_429` to benchmarks `catalog.toml` + vendor `suite.toml`; wire `scripts/ci.sh` optional gate; M1.5 TLS (`li-tls`, `setup-tls`).
4. **Blocked on:** `lic validate-config` in compiler CLI; per-route rate limits; proved `match_route` in `.li` (still Python oracle + C prefix table).

## Changed

| Area | Path | Evidence |
|------|------|----------|
| Rate limit | `runtime/li_rt_net.c` | Token bucket; 429 before dispatch |
| Routes | `runtime/li_rt_net.c`, `flatten-httpd-config.py` | `route=METHOD\|path\|kind\|action` |
| CLI | `scripts/explain-httpd-config.py`, `scripts/test-rate-limit-429.sh` | |
| Example | `packages/li-httpd/examples/rate_limit.toml` | |
| Plan | `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | Wave 4 marked done |

## Not changed

- TLS / HTTP/2 / WebSocket (M1.5 / M2).
- `packages/li-log`, auth/mTLS, SSE streaming.
- Full HTTP/1.1 parser proofs (P0-http).

## Breaking

N/A — additive config keys; default rate limit off when omitted.

## Security

429 reduces abuse under configured caps; not a substitute for auth or WAF.

## Performance

O(routes) prefix scan per request (≤16 routes); rate check O(1).

## Downstream

Benchmarks: add tier-5 `rate_limit_429` scenario + ingest row when validating dashboard HTTP section.
