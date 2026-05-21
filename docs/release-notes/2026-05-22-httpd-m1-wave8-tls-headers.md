# li-httpd M1 wave 8 — li-tls scaffold + response header policy

## Summary

Ports M1 wave-8 **scripts, examples, and `packages/li-tls` scaffold** onto current `lic` `main` — no `runtime/li_rt_net.c` changes in this PR (epoll integration is a separate rebase).

## Agent continuation

1. **Read** `packages/li-tls/README.md`, `packages/li-httpd/examples/header_strip_proxy.toml`.
2. **Run** `./scripts/test-strip-internal-headers.sh` (policy unit test + live proxy); `LI_SKIP_HEADER_STRIP_LIVE=1` for policy-only; `./scripts/lic-validate-httpd-config.sh packages/li-tls/examples/dev-self-signed.toml`.
3. **Then** wire **li-crypto** + record layer; enable `https_static` tier5 when `LI_HTTPD_TLS=1`.
4. **Blocked on** PH-2e / **li-crypto** for proved TLS 1.3.

## Changed

- `packages/li-tls/` — scaffold `li.toml`, `src/lib.li`, `examples/dev-self-signed.toml`.
- `scripts/flatten-httpd-config.py`, `validate-httpd-config.py` — `[headers]`, `[tls]` subset validators.
- `packages/li-httpd/examples/header_strip_proxy.toml`; `scripts/test-strip-internal-headers.sh`, `scripts/test-header-filter-policy.py`, `scripts/_run_header_strip_check.py`.
- `docs/ecosystem/why-li-rt-net-in-lic.md` — documents why the net seam stays in **lic** `runtime/`.

## Not changed

- `runtime/li_rt_net.c` / `runtime/li_rt_httpd.c` on `main` (stub net + routing oracle unchanged).
- TLS listen/terminate (no HTTPS port yet).
- Request header filtering (egress allowlist is M1.5).
- SSE / HTTP/2.
- **benchmarks** catalog (ingest-only; no harness copy).

## Breaking

N/A — `strip_internal_headers` defaults on; set `[headers] strip_internal = false` to disable.

## Security

Removes `x-internal-*` from proxied responses (CVE-class header leak mitigation on loopback bench path).

## Performance

N/A — O(headers) filter once per upstream response.

## Downstream

- **benchmarks:** `https_static` in nightly profile only; catalog `verify_skip`.
