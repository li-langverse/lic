# li-httpd M1 wave 5 — routing tests + li-log stub

## Summary

Expanded `li-tests/routing/` table cases (exact, prefix_strip, strict overlap reject) and added `packages/li-log` scaffold for access/audit logging.

## Agent continuation

1. **Read** `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` wave 5 row; `scripts/httpd_config.py` overlap rules.
2. **Run** `./li-tests/run_httpd_config.sh`; `LIC_ROOT=$PWD ./scripts/test-rate-limit-429.sh` after httpd rebuild.
3. **Then** wire `log_access_line` from C runtime; per-route rate keys; `lic validate-config` in-process.
4. **Blocked on** PH-2e Lean VC gate for full proof-backed route DSL in Li (not Python oracle).

## Changed

- `scripts/httpd_config.py` — exact/prefix overlap detection; `--strict-overlap` for reject tests.
- `li-tests/routing/cases/static_exact.toml`, `prefix_strip.toml`; `li-tests/httpd/fixtures/prefix_strip.toml`.
- `li-tests/config_desugar/reject/routing_overlap.toml`; `li-tests/run_httpd_config.sh`.
- `packages/li-log/` — `li.toml`, `src/lib.li`, README (stub).
- `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` — wave 5 row; `m1-routing-tests` completed.

## Not changed

- TLS / HTTP/2 / SSE (M1.5).
- Per-route rate limits (still global bucket in `li_rt_net.c`).
- `lic build` Lean verification pipeline (PH-2e).
- benchmarks `vendor/lis-tier5` (updated in benchmarks repo PR).

## Breaking

N/A — test-only and package stub; no public API change.

## Security

N/A — routing validator stricter on overlap; no new network surface.

## Performance

N/A — no hot-path change this wave.

## Downstream

- **benchmarks:** tier5 `rate_limit_429` scenario uses `LI_HTTPD_BIN` from this repo’s `build/li-httpd`.
