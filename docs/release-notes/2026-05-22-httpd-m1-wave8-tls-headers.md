# li-httpd M1 wave 8 — li-tls scaffold + response header policy

## Summary

Added `packages/li-tls` (M1.5 scaffold), default stripping of `x-internal-*` upstream response headers on the proxy path, and benchmarks nightly `https_static` row marked `verify_skip` until TLS terminates.

## Agent continuation

1. **Read** `packages/li-tls/README.md`, `packages/li-httpd/examples/header_strip_proxy.toml`.
2. **Run** `./scripts/test-strip-internal-headers.sh` (policy unit test + live proxy); `LI_SKIP_HEADER_STRIP_LIVE=1` for policy-only; `./scripts/lic-validate-httpd-config.sh packages/li-tls/examples/dev-self-signed.toml`.
3. **Then** wire **li-crypto** + record layer; enable `https_static` tier5 when `LI_HTTPD_TLS=1`.
4. **Blocked on** PH-2e / **li-crypto** for proved TLS 1.3.

## Changed

- `packages/li-tls/` — scaffold `li.toml`, `src/lib.li`, `examples/dev-self-signed.toml`.
- `runtime/li_rt_net.c` — `httpd_filter_proxy_resp_headers`, `strip_internal_headers` runtime key; cap `HTTPD_PREWARM_AT_START` (avoid listen stall); relay buffered body after header filter.
- `scripts/flatten-httpd-config.py`, `validate-httpd-config.py` — `[headers]`, `[tls]` subset.
- `packages/li-httpd/examples/header_strip_proxy.toml`; `scripts/test-strip-internal-headers.sh`, `scripts/test-header-filter-policy.py`, `scripts/_run_header_strip_check.py`.

## Not changed

- TLS listen/terminate (no HTTPS port yet).
- Request header filtering (egress allowlist is M1.5).
- SSE / HTTP/2.

## Breaking

N/A — `strip_internal_headers` defaults on; set `[headers] strip_internal = false` to disable.

## Security

Removes `x-internal-*` from proxied responses (CVE-class header leak mitigation on loopback bench path).

## Performance

N/A — O(headers) filter once per upstream response.

## Downstream

- **benchmarks:** `https_static` in nightly profile only; catalog `verify_skip`.
