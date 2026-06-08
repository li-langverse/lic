# PH-7e / G-math — pure-Li Horner lowering slice (tier-1 `horner_pure_li`)

> **Issue:** [#11](https://github.com/li-langverse/lic/issues/11) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-math; no threshold weakening), **Fast** (tier-1 ≤1.2× C++ after proof path is sound)  
> **Parent plans:** [math-linalg surface §7e](2026-05-16-li-math-linalg-surface.md), [master plan §7e](2026-05-14-li-master-plan.md), [tier-1 red honesty (#463)](2026-05-30-ph7e-tier1-red-benchmark-honesty.md)  
> **Learned from:** [bench-improver horner pass](../../numerics/bench-improver-horner-2026-05-20.md), [lexer autoresearch](../../numerics/autoresearch-horner-lexer-2026-05-18.md), [provability-gaps.md](../../verification/provability-gaps.md), [proof_gap cycle 18 Horner FMA drift](https://github.com/li-langverse/benchmarks/blob/main/data/digest/proof_gap_researcher-2026-05-30-horner-fma-literal-drift.md)

## Goal

Close the **honest** performance gap on tier-1 `horner_pure_li` (`variant = pure_li`) so Li compiles the benchmark kernel — `acc = acc * x + 1.0` over N steps — to **native FMA-class codegen** without user `__li_simd_*`, without `LI_EXTRA_C` kernels, and without weakening `threshold_ratio_cpp` in **benchmarks**. Dashboard red at **≈88×** is largely stale (pre-lexer `+` fix); post-fix local runs are **~3–11×** — still above the **≤1.2×** gate. This slice defines the compiler/MIR/codegen work to reach green and the doc gates that follow measured evidence.

**North star fit:** scientific computing micro-kernels · **PH-5b** (numerics codegen), **PH-7e** (math → SIMD/FMA lowering), **PH-2f** (FMA / `fp_numerically_stable` policy).

## Non-goals

- Lowering `threshold_ratio_cpp` or catalog thresholds in **benchmarks** to green incomplete kernels.
- Shipping `__li_simd_*` or intrinsics in tier-1 **Li** sources (`horner_pure_li/li/main.li` stays math-only).
- Adding Horner-specific C kernels via `LI_EXTRA_C` / `common/horner_core.c` in the Li column.
- Claiming **G-math** “closed slice” for `horner_pure_li` from documentation edits alone.
- Editing `trusted.lean` (human-approved issues only).
- Matrix `@` / `ArrayMatMul2DF64` SIMD matmul (deferred within **7e-b**; separate from this slice).

## Current evidence (2026-05-17 audit)

| Signal | Value | Interpretation |
|--------|-------|----------------|
| Dashboard `ratio_vs_cpp` | **≈88.8×** | Stale ingest; lexer `+` bug caused non-terminating / wrong loop ([autoresearch](../../numerics/autoresearch-horner-lexer-2026-05-18.md)) |
| Post-lexer local (honest sink) | **~3–11×** | Scalar or partial Horner MIR; FMA path exists but not matching C++ reference density |
| C++ reference | `common/horner_core.c` | Scalar FMA chain, N=5M, `x = 0.999999` |
| Li workload | `horner_pure_li/li/main.li` | `while i < 5000000; acc = acc * x + 1.0` — pure `BinOpFloat` + `while` |
| MIR (present) | `HornerFmaUnroll`, `HornerStepPow4`, `HornerConstLoopF64` | `compiler/mir/lower.cpp` pattern match; `emit.cpp` FMA emit |
| MIR (partial) | `ArrayDotF64` only for 1d `@` | Matrix `@` / blocked IKJ deferred per master plan |

## Dependencies

| ID | Role |
|----|------|
| **PH-7e** | Math/scalar loop → FMA MIR parent phase |
| **PH-5b** | Numerics micro-kernel bench policy |
| **PH-2f** | `fp_numerically_stable` gates FMA vs mul+add (`horner_fma_numerically_stable_gap.sh`) |
| **benchmarks** ingest | Refresh dashboard row after lic codegen lands — **no** harness copy into benchmarks |
| **#463** | Broader tier-1 red honesty; this slice is the `horner_pure_li` row owner |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **7e-d0** | **Repro matrix** — dashboard vs `check-tier1-li-vs-cpp.sh` vs local `bench.py --only horner_pure_li` | Table on #11: MIR op emitted (`HornerConstLoopF64` / scalar `while`), FMA insn count vs C++ |
| **7e-d1** | **Pattern match** — `lower.cpp` recognizes benchmark shape: `var x` with literal init, `while i < N` / `for`, `acc = acc * x + c` | `lic build` on `horner_pure_li/li/main.li` emits `HornerConstLoopF64` or unrolled FMA block (not scalar `BinOpFloat` loop body) |
| **7e-d2** | **Codegen density** — `HornerConstLoopF64` / `HornerStepPow4` emit ≥ C++ FMA throughput; LLVM loop unroll/vectorize where provably safe | `objdump` FMA count ≥ reference; `ratio_vs_cpp` ≤ **1.2×** on advisory tier-1 run |
| **7e-d3** | **G-meta FMA policy** — `emit_fma_f64` honors `--numerically-stable` on all Horner MIR ops (cycle 18 drift) | `li-tests/tooling/horner_fma_numerically_stable_gap.sh` PASS |
| **7e-d4** | **Anti-DCE contract** — volatile sink + harness checksum guard stays green | `bench.py` tier-1 verify: no `li_time < 0.45 × native`; checksum == native |
| **7e-d5** | **li-tests** — workload mirror + trip-edge probes | New/extended: `li-tests/math_linalg/horner_pure_li_mirror.li`, `horner_trip_edges.li` (64/65536 boundaries) |
| **7e-d6** | **G-math doc sync** — update `provability-gaps.md` **only** after **7e-d2** green on ingest | Retract premature “≤1.2× horner_pure_li” if still red; master plan §7e checkbox honest |

## Tests / benches

| Asset | Role |
|-------|------|
| `horner_pure_li` | Tier-1 bench id; `threshold_ratio_cpp = 1.2`; `ph_ids = ["PH-5b", "PH-7e"]` |
| `./scripts/check-tier1-li-vs-cpp.sh` | Advisory gate; strict with `LI_TIER1_PERF_STRICT=1` |
| `li-tests/math_linalg/horner_fma_codegen_probe.li` | FMA MIR smoke (trip ≥ 65536, const `x`) |
| `li-tests/tooling/horner_fma_numerically_stable_gap.sh` | G-meta / G-hw FMA policy |
| `li-tests/manifest.toml` | Regression: `+` lexes as `Plus` (horner loop counter) |
| `proof-db/numerics/lemmas/fp_horner_round_stub.li` | P-float stub; no new axioms in this slice |

**REQ traceability:** compiler Horner lowering is **REQ-COMPILER-7e-HORNER** (new row in master-plan tracker on implementation PR).

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-math** | Partial → honest Partial until green | **Retract** summary-table claim that `horner_pure_li` is in closed ≤1.2× slice while dashboard red |
| **G-meta** | Missing → Partial | Gate Horner FMA on `fp_numerically_stable` before tier-1 green |
| **G-hw** | Axiomatic | FMA ≠ mul+add documented; no new trusted axioms |
| **P-float** | Stub | `fp_horner_round_stub.li` remains stub; no discharge required for perf slice |

## Implementation sketch (for code agents post-`plan-approved`)

1. **MIR (`compiler/mir/lower.cpp`)**  
   - Treat `var x: float = <float_lit>` as const-fold candidate for `lookup_const_float`.  
   - Match `acc = acc * x + 1.0` when `x` is ident bound to literal (benchmark uses `0.999999`).  
   - For `N = 5_000_000`, prefer `HornerConstLoopF64` (chunked FMA) over per-iteration scalar `BinOpFloat`.  
   - Document trip divisibility rules (64 / 65536) in plan-cross-links.

2. **Codegen (`compiler/codegen/emit.cpp`)**  
   - Ensure `HornerConstLoopF64` inner loop uses `emit_fma_f64` and LLVM can vectorize chunk body.  
   - Align with C++ reference: one FMA per logical step, no heap alloc in hot path where avoidable.  
   - Mirror matmul policy: `--numerically-stable` → mulsd path, no `vfmadd`.

3. **No user-visible SIMD** — lowering is compiler-internal; audit via MIR dump tests only.

## Rollout

1. Human adds **`plan-approved`** on #11 (this PR).  
2. **lic** implementation PR(s): **7e-d1** → **7e-d3** → **7e-d2** (can be one PR if small).  
3. Local + CI: `check-tier1-li-vs-cpp.sh`, extended `math_linalg/` suite.  
4. **benchmarks** ingest refresh (normal nightly or `./scripts/run-full-benchmark-suite.sh`) — dashboard only.  
5. **7e-d6** doc PR: `provability-gaps.md` + master plan §7e checkbox when measured green.  
6. Close #11 when `ratio_vs_cpp ≤ 1.2` on ingest or waived via master-plan amendment (human-only).

## Human-only

- [ ] Label **`plan-approved`** on [#11](https://github.com/li-langverse/lic/issues/11) before codegen agents run.  
- [ ] Remove **`plan-needed`** after plan PR is linked on the issue.  
- [ ] Approve rare advisory waiver via master-plan edit — never silent catalog tweak.  
- [ ] Merge plan PR (draft → ready) after review.

## Relation to sibling issues

| Issue | Relationship |
|-------|----------------|
| [#463](https://github.com/li-langverse/lic/issues/463) | Parent tier-1 red honesty; sub-phase F for `horner_pure_li` delegates here |
| [#424](https://github.com/li-langverse/lic/issues/424) | G-math doc reconciliation — blocked until benches green |
| [#148](https://github.com/li-langverse/lic/issues/148) | Pure-Li tier-1 umbrella — partial; this slice completes Horner row |
