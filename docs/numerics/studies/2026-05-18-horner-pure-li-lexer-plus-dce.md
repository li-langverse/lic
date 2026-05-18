# Study: horner_pure_li 88× regression — lexer `+` and DCE

**Date:** 2026-05-18  
**PH:** PH-5b, PH-7e  
**Hypothesis:** Pure-Li codegen for `while` + `BinOpFloat` was pathologically slow.  
**Outcome:** **Rejected** (root cause was lexer + benchmark harness); fix restores parity.

## Findings

1. **Lexer bug:** `case '+':` fell through to `single(TokenKind::Minus)`, so `i = i + 1` lowered as subtraction. The while-loop became a signed countdown with wrap, and LLVM emitted `sub` instead of `add`.
2. **Benchmark honesty:** `acc` was dead (return `0`), so LLVM eliminated the Horner body entirely; wall time measured a broken loop, not Horner.
3. **Fix:** Emit `TokenKind::Plus` for `+`; call `li_rt_bench_sink_f64(acc)` (volatile global) before return.

## Evidence (tier-1, median of 3, arm64)

| lang | wall_time (s) | ratio vs cpp |
|------|---------------|--------------|
| cpp  | 0.0157        | 1.00         |
| li   | 0.0180        | **1.15**     |

Before fix: li ≈ 0.737 s (~47× on this machine; catalog had ~88×).

## Repro

```bash
./scripts/build.sh
python3 benchmarks/harness/bench.py --tier 1 --runs 3 --skip-verify
# row: benchmarks/results/latest.csv horner_pure_li
li-tests/run_all.sh  # lexer_parser/plus_minus.li
```

## Contracts / Lean

No new axioms. `li_rt_bench_sink_f64` is a trusted runtime I/O-adjacent sink (documented in `runtime/li_rt.c`).
