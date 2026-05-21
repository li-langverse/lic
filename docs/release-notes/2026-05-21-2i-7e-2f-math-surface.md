# 2i-b axpy/**/reductions, 2f axpy corpus, 7e tier-1 Li vs C++ reporter

## Summary

Closes the **2i-b** math surface slice (prelude `axpy`, same-length `**`, scalar×float-array, `math_linalg/reductions/`), grows **P-linalg** with `linalg_axpy4_int_closed`, and adds **`check-tier1-li-vs-cpp.sh`** to report tier-1 pure-Li vs C++ gaps (strict ≤1.2× optional).

## Agent continuation

1. **Read** `docs/verification/provability-gaps.md` § Still open; `scripts/check-tier1-li-vs-cpp.sh`; `li-tests/math_linalg/`.
2. **Run** `./scripts/build.sh && ./li-tests/run_all.sh math_linalg && ./li-tests/tooling/tier1_li_vs_cpp.sh`.
3. **Then** refresh `benchmarks/results/latest.csv` via `python3 benchmarks/harness/bench.py --tier 1`; close **G-math** tier-1 gaps (notably `matmul_naive`, `horner_pure_li`).
4. **Blocked on** float `@` Lean Props, 2D array CallProc codegen, default Lean kernel gate (**G-lean**).

## Changed

| Area | Paths / evidence |
|------|------------------|
| **2i-b** | `compiler/mir/lower.cpp` (`ArrayScaleF64`, `ArrayAxpyF64`, `**` in `ArrayBinOpF64`); `compiler/types/typecheck.cpp`, `prelude.cpp`; `li-tests/math_linalg/{elementwise_pow_float4,scale_float4,axpy_float4}.li`, `reductions/*.li` |
| **2f** | `li-tests/contracts_verify/linalg_axpy4_int_closed.li`; `discharge_linalg_int_lean.sh` |
| **7e** | `scripts/check-tier1-li-vs-cpp.sh`, `li-tests/tooling/tier1_li_vs_cpp.sh`; wired in `check-master-plan-gates.sh` (advisory) |
| **Docs** | `provability-gaps.md`, master plan, `proof-corpus-roadmap.md`, math-linalg plan |

## Not changed

- No default **`lic build`** Lean kernel failure on open Props (**G-lean**).
- No float `vec3_dot` / 2D matmul **CallProc** proof specimens.
- No `@parallel` MIR elaboration (**G-dec**).
- No org **benchmarks** catalog ingest (lic-local tier-1 CSV only).

## Breaking

N/A — additive prelude `axpy` and MIR ops; existing programs unchanged.

## Security

N/A — no trusted surface or CVE rows.

## Performance

Advisory tier-1 reporter only; does not change codegen. Known gaps vs C++ remain until PH-7e lowering work (see script output).

## Downstream

N/A — no pin changes in `lip`/`lit`/org benchmarks ingest in this PR.
