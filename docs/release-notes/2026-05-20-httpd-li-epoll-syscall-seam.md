# Li-native httpd epoll loop + syscall-only `li_rt_net`

## Summary

`packages/li-net-httpd` and `packages/li-net` serve static tier-5 HTTP from Li with a syscall-only `runtime/li_rt_net.c` seam (epoll, writev coalesce, index body cache, pipelined drain); loopback RPS is within ~60% of nginx on pipelined scenarios but not yet on serial `static_small`.

## Agent continuation

1. **Read:** `packages/li-net-httpd/src/lib.li`, `packages/li-net/src/lib.li`, `runtime/li_rt_net.c` (`httpd_prepare_root_i`, `httpd_drain_slot_i`, `tcp_send_coalesce_i` writev).
2. **Run:** `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; `LI_HTTPD_BIN=build/li-httpd python3 …/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py --profile ci`.
3. **Then:** fix lic MIR/codegen (`proc` returning `ptr` via early `return` in callee); move hot drain back into Li once borrow/`var` ergonomics allow; recover `static_small` parity (epoll batching / less per-request overhead).
4. **Blocked on:** `cursor[bot]` push 403 to **lic** — human push branch `cursor/httpd-m1-perf-54aa`.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | Syscall-only: epoll (ET clients), `writev` coalesce, slot pool, `httpd_prepare_root_i` + cached index body, `httpd_drain_slot_i` pipelined GET `/` |
| `runtime/li_rt.h` | Declarations for slot hdr, cache, drain, listen epoll add |
| `packages/li-net/src/lib.li` | `extern proc` surface; read-only ptr args use `var ptr` so callers are not moved |
| `packages/li-net-httpd/src/lib.li` | Li epoll/blocking orchestration; Li fallback `try_drain_slot` when cache missing |
| `CHANGELOG.md` | Unreleased httpd perf + seam bullets |

## Not changed

- **lis** / **benchmarks** harness TOML (`static_small` still `pipeline=1` — serial per connection).
- TLS, HTTP/2, path traversal hardening beyond bench fixture.
- Compiler `ptr` return from nested `proc` (workaround: inline filepath in `serve_one_request`, no `fp =` reassign).

## Breaking

N/A — tier-5 bench binary only.

## Security

Same trusted seam: loopback bind, static GET only; drain fast path accepts `GET /` and `/index.html` only.

## Performance

`bench_http.py --profile ci` (loopback, ~100 B `index.html`):

| Scenario | nginx RPS | li RPS | li/nginx |
|----------|-----------|--------|----------|
| `static_small` | ~84k | ~6.5k | ~0.08 |
| `keepalive_pipelining` | ~96k | ~58k | ~0.60 |

Gap on `static_small` is mostly serial requests per connection (no wrk pipeline) plus epoll/Li call overhead; pipelined scenario is closer to M1 target.

## Downstream

- Re-ingest `vendor/lis-tier5/results/latest.csv` into **benchmarks** after merge.
- File lic issue: `proc` early `return` of `ptr`; optional restore pure-Li drain when fixed.
