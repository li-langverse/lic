# HTTP nginx gap phase 2 (plan loop)

## New plan todos (`gap-phase2-*`)

| Id | Closes |
|----|--------|
| `gap-phase2-perf-wrk-soak` | Full wrk timing vs nginx (parity + nextjs + regression gate) — **completed** |
| `gap-phase2-mitigation-exploits` | All `nginx_mitigations.toml` rows linked to exploit TOMLs + drivers (**completed**) |
| `gap-phase2-streaming-wrk` | SSE/WS streaming soak with timing, not verify-only |
| `gap-phase2-exploit-nginx-regression` | Live exploit compare — no nginx-pass / li-fail regressions (**completed**) |

## Gates

- `check-tier5-perf-wrk-soak.sh` — `HTTPD_BENCH_SKIP_TIMING=0`, `HTTPD_BENCH_DURATION_SEC=30`, parity + `parity_streaming` + nextjs (documented `proxy_loopback` / `sse_verify` bars in scenario `bench.toml`)
- `check-tier5-mitigation-exploits-complete.sh`
- `check-tier5-exploit-nginx-regression.sh`
- Phase-2 hooks run when `HTTPD_RUN_PHASE2_GATES=1` (set by `httpd-plan-loop.py` on `gap-phase2-*` todos).

### Exploit nginx regression (`gap-phase2-exploit-nginx-regression`)

- `./scripts/build-tier5-nginx-oracle.sh` then `./scripts/check-tier5-exploit-nginx-regression.sh`
- Harness: per-lang free ports, nginx `daemon off`, `--fail-on-regression` counts **li** failures and nginx-pass/li-fail only
- Runtime: duplicate `Content-Length` checked before `/file.bin` fast path
- Drivers: `oversized_body`, `h2_rapid_reset`, `dns_validate_config` (external upstream peer reject); static fixtures get `index.html` for legitimate GET probes

## Loop behavior

- Pending `gap-*` todos are scheduled **before** other milestones.
- `httpd-plan-run-gap-parity.sh` defaults to `LI_HTTPD_PLAN_GAP_ONLY=1`.
