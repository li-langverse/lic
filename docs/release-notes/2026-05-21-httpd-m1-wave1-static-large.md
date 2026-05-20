# li-httpd M1 wave 1 — generic static + static_large bench

## Summary

Extends the C epoll hot path to serve any safe GET path under the document root (sendfile for large files), adds `static_large` tier-5 scenario, and ships a minimal `li-httpd.toml` validator script.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_send_static_path`, `path_is_safe`); `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` (Implementation status); `scripts/validate-httpd-config.py`.
2. **Run:** `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; `python3 scripts/validate-httpd-config.py`; `bench_http.py static_large --profile ci` with `LI_HTTPD_BIN`.
3. **Then:** M1 wave 2 — `proxy_loopback` + typed upstream in Li; wire `exploit_http.py` to li-httpd.
4. **Blocked on:** `lic validate-config` subcommand — use Python script until HTTP config module exists.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | `g_doc_root`, `parse_get_path_c`, `httpd_send_static_path`, index fast path preserved |
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | Implementation status + M1 waves + todo states |
| `packages/li-httpd/examples/minimal.toml` | Example config |
| `scripts/validate-httpd-config.py` | M1 subset validator |
| `docs/ecosystem/httpd-prerequisites.md` | P0-net static_large note |

## Not changed

- Reverse proxy, load balancing, TLS, HTTP/2, rate limits (M1 wave 2+).
- **lis** harness in org repo — sync `tier5_http` from benchmarks vendor tree after merge.
- Compiler Lean VC gate (2e–2f).

## Breaking

N/A

## Security

Path traversal guard in C (`path_is_safe`, no `..`); proxy routes rejected by validate script until allowlisted upstreams exist.

## Performance

`static_large` (`bench_http.py --profile ci`, 1 MiB `file.bin`, wrk `/file.bin`):

| lang | RPS (approx) |
|------|----------------|
| nginx | 9,367 |
| li | 9,559 |

## Downstream

- **benchmarks:** `catalog.toml` row `static_large`; vendor `tier5_http` suite + harness `url_path` + fixture generator.
