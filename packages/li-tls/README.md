# li-tls (M1.5 scaffold)

TLS 1.3 termination for **li-httpd** — self-signed dev certs and ACME (Let's Encrypt) per [httpd plan](../../docs/superpowers/plans/2026-05-16-li-httpd-plan.md).

## Status

**Scaffold only** — no record layer or handshake in this repo yet. Depends on **li-crypto** / **li-rng** policy gates (see plan `rng_prng_on_tls`).

## Planned API (`src/lib.li`)

| Symbol | Purpose |
|--------|---------|
| `tls_dev_self_signed_load` | Dev profile: load or generate `cert.pem` + `key.pem` |
| `tls_listen_wrap` | Wrap accepted TCP fd → TLS server connection |
| `tls_acme_renew` | M1.5+: ACME HTTP-01 via **li-acme** |

## Bench

- benchmarks tier5 `https_static` — harness skips until `LI_HTTPD_TLS=1` and `build/li-httpd` links TLS.

## Next

1. ChaCha20-Poly1305 + X25519 in **li-crypto** (plan Phase H).
2. `server.tls = "self_signed"` in TOML → flatten `tls_mode=self_signed`.
3. Tier5 `https_static` verify row green in nightly.
