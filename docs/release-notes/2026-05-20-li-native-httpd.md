# Li-native tier-5 static HTTP server

## Summary

Moves the tier-5 `li-httpd` accept/parse/keep-alive/pipeline loop into `packages/li-net-httpd/src/lib.li`, leaving `runtime/li_rt_net.c` as syscall and buffer primitives only, and fixes `lic` codegen so imported `extern` calls emit correctly.

## Agent continuation

1. **Read:** `packages/li-net-httpd/src/lib.li` (serve loop), `runtime/li_rt_net.c` (primitives `tcp_*`, `*_i`, `httpd_send_*_i`), `compiler/codegen/emit.cpp` (extern declare pass).
2. **Run:** `cmake --build build -j4`; `./build/compiler/lic/lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; curl `http://127.0.0.1:<port>/` with `index.html` under doc root; `LI_HTTPD_BIN=build/li-httpd python3 vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py --profile ci`.
3. **Then:** port Linux `epoll` accept loop to Li (or thin `httpd_epoll_once` extern) to recover M1 RPS vs nginx; file lic issue for `var str` local MIR lowering (use `ptr` / `*_i` handles until fixed).
4. **Blocked on:** bot push 403 to **lic** — human push branch `cursor/httpd-m1-perf-54aa`.

## Changed

| Path | Evidence |
|------|----------|
| `packages/li-net-httpd/src/lib.li` | Li `httpd_serve_static_blocking`, keep-alive drain, GET path → `str_path_join` / `index.html` |
| `runtime/li_rt_net.c`, `runtime/li_rt.h` | Syscall seam only; `intptr_t` `*_i` helpers; `httpd_send_reply_i` / `httpd_send_404_i` |
| `compiler/codegen/emit.cpp` | Two-pass emit: declare all `extern` before Li function bodies (fixes missing `tcp_listen` calls) |
| `compiler/mir/lower.cpp` | `ptr`/`i64` params and returns; `import_name` path deps (with `import_resolve.cpp`) |
| `compiler/types/import_resolve.cpp` | Workspace `import_name` + import-not-found errors |
| `CHANGELOG.md` | Unreleased Li-native httpd + compiler bullets |

## Not changed

- **benchmarks** `summary.json` / dashboard ingest (run ingest after lic merge).
- TLS, HTTP/2, directory traversal policy beyond bench fixture.
- **nginx oracle** harness (`bench_http.py`) — unchanged; still compares `LI_HTTPD_BIN`.

## Breaking

N/A — tier-5 bench binary entry is still `build/li-httpd`; build via `lib.li` (includes `main`).

## Security

Same M0 tier-5 posture: loopback bind, static GET only; trusted C for sockets/IO primitives.

## Performance

`bench_http.py --profile ci` after Li-native port (this tree):

| Scenario | nginx RPS | li RPS |
|----------|-----------|--------|
| `static_small` | ~83k | ~4.8k |
| `keepalive_pipelining` | ~96k | ~9.6k |

Correctness and Li-first structure land first; **epoll/M1 C accept path was removed** with the monolith — restore in Li or a minimal extern loop next.

## Downstream

- Re-run tier-5 ingest into **benchmarks** when lic tag/SHA updates.
- Agents: use `ptr` for opaque C string handles until `var str` local lowering is fixed in `lic`.
