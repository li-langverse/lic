# Study: bench_improver proactive pass (2026-05-30)

**Agent:** bench_improver · **Run:** bench_improver-1780151403273 · **Source:** proactive  
**North star fit:** blazingly-fast numerics (**PH-5b**, **PH-7e**)

## Dashboard snapshot (ingest 2026-05-30T09:25Z)

| Status | Count | IDs |
|--------|------:|-----|
| RED | 0 | — |
| YELLOW | 2 | `matmul_blocked` (1.244×), `matmul_naive` (1.222×) |
| Near threshold | 3 | `num_integ_rk4` (1.083×), `simd_dot` (1.052×), `fft_1d_fixed` (1.007×) |
| GREEN | 20 | tier-1 compare rows |

## Local repro (this pass, Release)

```bash
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 10
LI_TIER1_PERF_STRICT=0 ../scripts/check-tier1-li-vs-cpp.sh
```

| benchmark | cpp (s) | li (s) | ratio | verify |
|-----------|---------|--------|-------|--------|
| `matmul_naive` | 0.0017 | 0.0020 | **1.176×** | ok `161055.1865999999` |
| `matmul_blocked` | 0.0085 | 0.0108 | **1.271×** | ok `1288460.7563999966` |

PR [#524](https://github.com/li-langverse/lic/pull/524) tile harness **reverted**: Li checksum was `0` (failed DCE guard / wrong workload). Restored `mm_blocked_512` MIR hook.

## Harness fix (this pass)

`bench.py` verify path used `TimingStats` as float → `TypeError` on DCE guard. Fixed to use `.mean`.

## Quality table

| Axis | Dashboard | After PR #524 + local | This pass |
|------|-----------|----------------------|-----------|
| Speed reds | 0 | matmul_naive ≤1.2× local | matmul_blocked 1.271×; PR #524 harness reverted |
| Accuracy | verify ok | unchanged | unchanged |
| Stability | tier-0 skip | not touched | not touched |

## Commands (ingest — benchmarks repo)

```bash
cd benchmarks
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```

## Deferred

- `matmul_blocked` PH-7e: BSS/global hoist for 512² arrays + blocked `@` emit tuning (~6% needed).
- `matmul_naive` ingest variance on slow hosts (local 1.176× clears cap).
- `ml_*` stubs → `li-math` + `numerics_researcher`.
- Tier-2 CFD rows flipped to `skip` (harness_not_wired) — separate wiring task.
