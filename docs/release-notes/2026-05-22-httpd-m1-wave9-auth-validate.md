# li-httpd M1 wave 9 — validate-httpd-config + Bearer auth

## Summary

Added `lic validate-httpd-config` (wraps Python schema) and M1 Bearer API key gate (`401` without valid `Authorization: Bearer`).

## Agent continuation

1. **Read** `packages/li-httpd/examples/auth_bearer.toml`, `compiler/lic/main.cpp` (`validate-httpd-config`).
2. **Run** `./scripts/test-auth-bearer.sh`; `lic validate-httpd-config packages/li-httpd/examples/auth_bearer.toml`.
3. **Then** M1.5 SSE + stream idle timeout; hash keys at edge (no plaintext in prod configs).
4. **Blocked on** `li-crypto` / `li-tls` for TLS terminate and key hashing.

## Changed

- `compiler/lic/main.cpp` — `lic validate-httpd-config <toml>`.
- `scripts/lic-validate-httpd-config.sh` — prefers built `lic` when present.
- `runtime/li_rt_net.c` — `auth_required`, `auth_key=` runtime keys; `401 Unauthorized`.
- `scripts/flatten-httpd-config.py`, `validate-httpd-config.py` — `[auth]` section.
- `packages/li-httpd/examples/auth_bearer.toml`; `scripts/test-auth-bearer.sh`; `scripts/ci.sh`.

## Not changed

- Per-route auth exemptions (all routes share gate when enabled).
- mTLS, hashed key store, or `api_key` rate-limit key selection.
- TLS listen / SSE.

## Breaking

N/A — auth off unless `[auth] require_bearer = true`.

## Security

Closes unauthenticated access on dev/bench listeners when auth enabled; keys are plaintext in TOML (M1 dev only — document hash in M1.5).

## Performance

N/A — O(keys) strcmp on Bearer token per request.

## Downstream

- **benchmarks:** optional `auth_401` tier5 row when catalog needs it.
