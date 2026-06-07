---
workflow_repo: lic
branch: cursor/pure-li-https
plan: docs/superpowers/plans/pure-li-https-k8s.md
---

# Pure Li HTTPS — goal-directed sprint

## North star

Ship **pure Li TLS 1.3 terminate** on li-httpd: `li-crypto` + `li-tls` + httpd wiring. No OpenSSL on the hot path. Accept HTTPS with Ed25519/ECDSA/RSA PEM keys.

## Iteration rules

1. Read `data/pure-li-https-loop/state.json` for the current milestone.
2. Implement **only** that milestone; commit + push to `cursor/pure-li-https` every iteration.
3. Run the milestone gate before ending the iteration.
4. Append one row to `data/pure-li-https-loop/iteration-log.md`.
5. Do not mark the sprint done until `scripts/https-gates/pure-li-https-completion-gate.sh` passes.

## Phase checklist

| Phase | Milestone key | Deliverable | Gate |
|-------|---------------|-------------|------|
| M1a | `m1-crypto` | SHA-256/384, HKDF, ChaCha20-Poly1305, X25519, `li_rt_rng.c` | `bash scripts/https-gates/m1-crypto-primitives-gate.sh` |
| M1b | `m1-pem` | PEM scanner, X509 subset, Ed25519 key load | `bash scripts/https-gates/m1-pem-ed25519-gate.sh` |
| M2 | `m2-tls` | TLS 1.3 server handshake + record layer in `li-tls` | `bash scripts/https-gates/m2-tls-handshake-gate.sh` |
| M3 | `m3-httpd` | httpd proxy loop wired; curl smoke | `bash scripts/https-gates/m3-httpd-curl-gate.sh` |
| M4 | `m4-bench` | Cross-impl validity + security + perf vs C/OpenSSL/Rust | `bash scripts/https-gates/m4-benchmark-matrix-gate.sh` |

Advance `state.json` → next milestone only when the gate for the current milestone passes.

## Do not

- Put OpenSSL/libssl/libcrypto on the TLS hot path.
- Add crypto algorithms to `lic/runtime/*.c` (no `li_rt_crypto.c` — **everything is in Li**).
- Implement SHA/AEAD/X25519/Ed25519 in C "for speed"; use `lic/packages/li-crypto/src/*.li` only.
- Implement ACME in-runtime until M3+ is stable.
- Block M1 on RSA/ECDSA server keys (Ed25519 first).
- Mark done without `pure-li-https-completion-gate.sh` **and** cross-impl validity matrix green.
- Skip oracle comparison ("Li-only tests are enough") — always benchmark vs C native, OpenSSL, and Rust.

## Completion gate

```bash
bash scripts/https-gates/pure-li-https-completion-gate.sh
```
