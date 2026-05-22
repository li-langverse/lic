# Release notes: tier5_http bench harness (bench-harness)

**Branch:** `cursor/httpd-plan-continue`

## Summary

TOML-driven tier-5 HTTP benchmark harness: `defaults.toml`, `suite.toml`, per-scenario `bench.toml`, and Python drivers that resolve scenarios from suite config only (no hardcoded scenario lists).

## Agent continuation

1. **Run** `./scripts/check-tier5-http-harness.sh` and `./scripts/httpd-plan-gates.sh`.
2. **Next plan todos:** `nginx-src-audit`, `exploit_http.py` (exploit-harness), wire li-httpd load paths when `build/li-httpd` is stable on CI.
3. **Benchmarks repo:** refresh HTTP matrix via `../benchmarks` when nginx+wrk timing rows are captured (`SKIP_BENCH=1` for docs-only).

## Changed

- `benchmarks/tier5_http/` — `defaults.toml`, `suite.toml`, `scenarios/*/bench.toml`, `templates/nginx.conf.in`, `README.md`
- `benchmarks/harness/http_bench_toml.py`, `bench_http.py`, `verify_http.py`, `plot_http.py` (stub)
- `scripts/check-tier5-http-harness.sh`, `scripts/httpd-plan-gates.sh`
- `docs/benchmarks-http.md`
- Plan todo `bench-harness` → `completed`

## Not changed

- `exploit_http.py` / `audit_nginx_src.py` (later todos)
- Live Pages bench refresh (no new timing CSV this slice)
- Full li-httpd wrk parity runs (nginx+wrk optional; CI uses stub verify)

## Breaking / Security / Performance / Downstream

| Area | Note |
|------|------|
| Breaking | N/A — new harness paths |
| Security | N/A |
| Performance | N/A in CI; baseline profile runs wrk when tools present |
| Downstream | `suite_exploits.toml` unchanged; exploit drivers pending |
