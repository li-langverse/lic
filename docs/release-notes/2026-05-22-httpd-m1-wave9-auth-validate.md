# li-httpd M1 wave 9 — validate-httpd-config + Bearer auth

## Summary

Ports M1 wave-9 **config validators and auth test scripts** onto current `lic` `main` — uses existing `lic httpd validate-config` on `main`; does not add `validate-httpd-config` subcommand or Bearer logic to `li_rt_net.c` in this PR.

## Agent continuation

1. **Read** `packages/li-httpd/examples/auth_bearer.toml`, `compiler/lic/main.cpp` (`validate-httpd-config`).
2. **Run** `./scripts/test-auth-bearer.sh`; `lic validate-httpd-config packages/li-httpd/examples/auth_bearer.toml`.
3. **Then** M1.5 SSE + stream idle timeout; hash keys at edge (no plaintext in prod configs).
4. **Blocked on** `li-crypto` / `li-tls` for TLS terminate and key hashing.

## Changed

- `scripts/lic-validate-httpd-config.sh` — wraps `lic httpd validate-config` when `build/compiler/lic/lic` exists, else Python validator.
- `scripts/flatten-httpd-config.py`, `validate-httpd-config.py` — `[auth]` section schema for CI/offline checks.
- `packages/li-httpd/examples/auth_bearer.toml`; `scripts/test-auth-bearer.sh` (live test **skipped** until epoll branch lands Bearer in `li_rt_net.c`).

## Not changed

- `compiler/lic/main.cpp` subcommands (no new `validate-httpd-config` name on `main`).
- `runtime/li_rt_net.c` Bearer gate (follow-up epoll rebase PR).
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
