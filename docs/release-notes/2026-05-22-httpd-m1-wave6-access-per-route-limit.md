# li-httpd M1 wave 6 — access log + per-route rate limits

## Summary

li-httpd emits RFC3339 access lines on stderr and supports per-route token buckets via `[route_limits]` in TOML (flattened to extended `route=` runtime rows).

## Agent continuation

1. **Read** `packages/li-httpd/examples/rate_limit_per_route.toml`; `runtime/li_rt_net.c` `httpd_rate_limit_allow_request`.
2. **Run** `./scripts/test-rate-limit-429.sh`; `./scripts/test-rate-limit-per-route.sh`; rebuild with `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`.
3. **Then** `LI_HTTPD_ACCESS_LOG=1` file sink in `li-log`; passive upstream health; in-process `lic validate-config`.
4. **Blocked on** api_key-scoped buckets (M1.5 `[route.rate_limit]` schema).

## Changed

- `runtime/li_rt_net.c` — `httpd_access_log`, per-route buckets, `httpd_match_route_index`.
- `scripts/httpd_config.py` — `[route_limits]`; `flatten-httpd-config.py` 6-field `route=` lines.
- `packages/li-httpd/examples/rate_limit_per_route.toml`; `scripts/test-rate-limit-per-route.sh`; `scripts/ci.sh`.
- Plan wave 6 row in `docs/superpowers/plans/2026-05-16-li-httpd-plan.md`.

## Not changed

- TLS, SSE, HTTP/2.
- Global-only nginx oracle benches (per-route is li-only).
- Lean VC / proof gate.

## Breaking

N/A — additive config keys; default behavior unchanged when `[route_limits]` omitted.

## Security

Per-route limits reduce abuse surface on exposed API prefixes; access log avoids logging Authorization (not parsed in access line).

## Performance

N/A — O(routes) match per request; negligible vs I/O.

## Downstream

- **benchmarks:** rerun `./scripts/httpd-masterplan-step.sh` after merging; `rate_limit_429` still global-only scenario.
