# provability_holes — cycle 14 (G-net trusted/codegen/seam recv-send drift)

**Run:** `proof_gap_researcher-2026-05-29-net-trusted-codegen-drift` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2f, PH-H

## Focus

**G-net / G-trust:** Legacy `tcp_recv`/`tcp_send` C ptr ABI in `emit.cpp` vs `tcp_*_stub : Net Nat` in `trusted.lean` vs slot/buffer procs in `seam.li`.

## Harness

```bash
bash li-tests/tooling/net_trusted_codegen_drift.sh
bash scripts/check-w0-bytes-io.sh   # includes drift regression
lic check li-tests/net_trusted/seam_policy_ok.li
```

## Key evidence

| Layer | Recv | Send |
|-------|------|------|
| `emit.cpp:1349-1354` | `i8*` return | `(conn, i8*)` |
| `trusted.lean:33-36` | `Nat → Nat → Net Nat` | `Nat → Nat → Net Nat` |
| `seam.li` | `tcp_recv_slot`, `tcp_recv_nb_i` | `tcp_send_buf`, `tcp_send_nb_i`, … |

Full session digest: benchmarks `data/runs/proof_gap_researcher-2026-05-29-net-trusted-codegen-drift.md`.
