# Bench improver pass — `horner_pure_li` (2026-05-20)

## Dashboard vs harness

| Source | `horner_pure_li` li/cpp | Notes |
|--------|-------------------------|-------|
| Public `summary.json` (2026-05-16 ingest) | **88.82×** | Stale: pre-`+` lexer fix; loop did not increment |
| Local tier-1 (DCE, `acc` unused) | **0.57×** | Bogus green — LLVM deleted the Horner loop |
| Local tier-1 (this pass, `li_rt_volatile_sink_f64`) | **9.5×** | Honest pure-Li scalar codegen vs native C reference |

Evidence rows (`benchmarks/results/latest.csv` on this branch, median of 5):

```csv
horner_pure_li,cpp,...,wall_time,0.0010,s,...
horner_pure_li,li,...,wall_time,0.0095,s,...
```

## Changes

1. **`li_rt_volatile_sink_f64`** — runtime volatile store (matches cpp `volatile` checksum sink).
2. **`horner_pure_li/li/main.li`** — call sink after loop; `raises IO` on `main`.
3. **`bench.py`** — pure_li verify fails if `li_time < 0.45 × native` (DCE guard).

## Status vs ≤1.2× cpp gate

Still **red** (9.5×). Next work is **PH-7e** codegen (SIMD/unroll Horner), not catalog threshold edits. Lexer `Plus` fix is already on `main` ([autoresearch-horner-lexer-2026-05-18.md](./autoresearch-horner-lexer-2026-05-18.md)).

## Near-limit tier-2 (deferred)

`matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain` are 1.02–1.03× on stale dashboard — shared C kernels; no harness change in this PR.
