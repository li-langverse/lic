# Autoresearch proactive sweep — tier-1 pure-Li gate survey (2026-05-29)

**Agent:** `autoresearch` · **Run:** `autoresearch-1780056266456` · **Source:** proactive  
**North star:** PH-5b (proved numerics), PH-7e (math→SIMD / pure-Li codegen) · **Mode:** survey + local bench (no novel-algorithm PR)

## Hypothesis (falsifiable)

| ID | Hypothesis | Metric | Outcome |
|----|------------|--------|---------|
| H1 | A **novel** tier-1 pure-Li numerical method is needed when org dashboard shows `*_pure_li` **red** | `ratio_vs_cpp` ≤ 1.2×, validity pass | **Rejected** — ecosystem audit **0 red**; only catalog `variant = pure_li` is `horner_pure_li` |
| H2 | Near-threshold **tier-2** physics (e.g. `md_lennard_jones` @ 1.2×) warrants autoresearch (new integrator/limiter) this pass | Stability + oracle parity + ≥5% speed | **Deferred** — shared `md_core` oracle; SOTA survey (`2026-05-27-md-r0-sota-survey.md`) routes **105** to implementation, not invention |
| H3 | Local devbox can reproduce ingest **yellow** `matmul_blocked` without codegen change | `li/cpp` wall time | **Confirmed** ~**1.27×** (see commands) — sibling `bench_improver` owns PH-7e fusion PR |

## Local measurements (this host)

```bash
cd lic && ./scripts/build.sh
cd benchmarks/harness
python3 bench.py --tier 1 --only horner_pure_li,matmul_blocked --runs 5 --skip-verify
python3 bench.py --tier 1 --only horner_pure_li,matmul_blocked --runs 3 --verify-results
```

| Bench | cpp (s) | li (s) | ratio | Verify |
|-------|---------|--------|-------|--------|
| `horner_pure_li` | 0.0006 | 0.0004 | **0.67×** | **FAIL** — Li uses `x=0.999999`; native oracle `x=1.1` → `inf` vs finite (documented in release notes) |
| `matmul_blocked` | 0.0088 | 0.0112 | **1.27×** | **PASS** pure-Li checksum `1288460.7563999966` |

Horner **speed** meets ≤1.2×; **validity** path needs harness/oracle alignment (bench_improver / codegen policy), not a new Horner scheme.

## Quality table (locked axes)

| Axis | `horner_pure_li` | `matmul_blocked` | Notes |
|------|------------------|------------------|-------|
| Speed | Green locally (0.67×) | Yellow (~1.27× ingest 1.253×) | Ingest stale for horner/reduce |
| Stability | N/A tier-1 | N/A | |
| Accuracy / validity | Verify fail (oracle x) | ULP ~4 vs iterative ref | Within float noise; catalog ok |
| Memory | — | — | |

## Learned from (no novel method shipped)

1. **Hairer et al.** — Horner recurrence is SOTA for polynomial eval; Li MIR already emits `HornerConstLoopF64` / FMA unroll (`compiler/mir/lower.cpp`).
2. **BLIS/Goto** — blocked GEMM is SOTA; gap is **codegen** (`mm_blocked_512` MIR + LLVM), not a new multiply algorithm.
3. **LAMMPS cell lists** — next MD win is **algo 105 implementation** after numerics_researcher parity plan, not autoresearch invention this week.

## Negative result (valuable)

**Do not open a `novel-algorithm` PR** for this sweep: no axis improves via a new discrete scheme without regressing oracle policy. Tier-1 work stays **PH-7e codegen** (`bench_improver`); tier-2 MD stays **numerics_researcher → implementation** per `md-r0` / `md-r2` studies.

## Repro / ingest

- CSV: `lic/benchmarks/results/latest.csv` (tier-1 rows appended this run)
- Dashboard refresh: `benchmarks` repo `./scripts/ingest/ingest-lic.sh` (not run here — benchmarks workspace dirty)

## Related

- [bench-improver digest](../../../../benchmarks/data/latest/bench-improver-digest-2026-05-29.md) — `matmul_blocked` fusion pass
- [2026-05-27-md-r0-sota-survey.md](./2026-05-27-md-r0-sota-survey.md)
- [bench-improver-horner-2026-05-20.md](../bench-improver-horner-2026-05-20.md)
