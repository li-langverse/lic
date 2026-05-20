# li-httpd M0 — static serve via trusted Net seam

## Summary

Adds POSIX `tcp_*` + blocking static HTTP/1.1 server in `runtime/li_rt_net.c` and a buildable `li-httpd` binary (`packages/li-net-httpd`) for tier-5 nginx oracle benches.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c`, `packages/li-net-httpd/src/main.li`, `docs/ecosystem/httpd-prerequisites.md`.
2. **Run:** `./scripts/build.sh` then `./build/compiler/lic/lic build packages/li-net-httpd/src/main.li -o build/li-httpd`; set `LI_HTTPD_BIN=build/li-httpd` in **lis** `bench_http.py`.
3. **Then:** parser proofs, config router, async reactor — not M0 scope.
4. **Blocked on:** Lean discharge for full `raises Net` policy; bench uses trusted C seam intentionally.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | tcp + static GET + fork/worker |
| `packages/li-net-httpd/src/*` | `httpd_run_from_argv` CLI |
| `compiler/codegen/compile.cpp` | link `li_rt_net.c` |

## Not changed

- Full HTTP/1.1 parser proofs (P0-http).
- TLS, HTTP/2, routing TOML desugar in Li.

## Breaking

N/A

## Security

Loopback bind; static files only; no path traversal hardening beyond realpath-style join — bench fixture root only.

## Performance

M0 fork-per-connection; ~5× slower than nginx on small static fixture (superseded by M1 keep-alive/epoll — see `2026-05-20-httpd-m1-keepalive-perf.md`).

## Downstream

**lis** / **benchmarks** `LI_HTTPD_BIN`; dashboard `ratio_vs_reference` vs nginx.
