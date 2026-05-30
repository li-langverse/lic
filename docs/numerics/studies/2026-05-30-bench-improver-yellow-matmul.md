# Study: tier-1 matmul yellow rows — assessment pass

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** blazingly-fast numerics (PH-5b / PH-7e)

## Problem

Org briefing listed six tier-1 **red** rows (`matmul_*`, `ml_*`, `num_gmres`). Fresh `benchmark-failures-report.sh` on ingested `summary.json` (2026-05-30T09:25Z) shows **RED: none**; remaining gaps are **yellow**:

| benchmark | ratio vs cpp | owner |
|-----------|--------------|-------|
| `matmul_blocked` | **1.244×** | lic pure-Li |
| `matmul_naive` | **1.222×** | lic pure-Li |

Target: tier-1 advisory **≤1.2×** cpp (`threshold_ratio_cpp`).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLIS) | Blocked IKJ BK=64 matches `matmul_blocked_core.c` |
| LLVM `llvm.fmuladd` + 4-wide `j` | Already in `emit_matmul2d_*` (PR #543) |
| Org oracle `matmul_core.c` | 256³ plain IKJ; **not** cache-blocked |
| Prior study `2026-05-30-bench-improver-tier1-matmul-mir.md` | MIR hooks `mm_naive_256` / `mm_blocked_512` restored |

## Local repro (this host, `79da702b`, Release)

```bash
cd lic && ./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
cd benchmarks/harness
python3 bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 10
LI_TIER1_PERF_STRICT=0 ../scripts/check-tier1-li-vs-cpp.sh
```

| benchmark | cpp | li | ratio | verify |
|-----------|-----|-----|-------|--------|
| `matmul_naive` | 0.0018s | 0.0021–0.0023s | **1.17–1.22×** | ok `161055.1865999999` |
| `matmul_blocked` | 0.0089–0.0091s | 0.0113–0.0117s | **1.25–1.31×** | ok `1288460.7563999966` |

## Experiments (not merged)

| Change | `matmul_naive` | `matmul_blocked` | Verdict |
|--------|----------------|------------------|---------|
| Route 256³ `@` via plain IKJ (`n>=512` blocked threshold) | ~1.22× (regression vs blocked @256) | — | **Reject** — keep blocked path for 256³ in `ArrayMatMul2DF64` |
| `llvm.prefetch` on B rows in blocked kernel | — | ~1.31× | **Reject** |
| Incomplete BSS hoist for ≥512² matrices | build break | — | **Defer** — needs `ArraySlot` helper migration |
| PR #524 harness: 512×(64³) tiled reps | — | 0.044× (verify **fail**) | **Revert** — DCE guard; unfair vs C 512³ oracle |

## Pass 2 (2026-05-30T14:55Z, `4ddbd3c6`)

Reverted `matmul_blocked/li/main.li` to fair `mm_blocked_512` (512×512, BK=64 MIR). Fixed `bench.py` verify guard (`TimingStats.mean`).

| benchmark | cpp | li | ratio | verify |
|-----------|-----|-----|-------|--------|
| `matmul_naive` | 0.0018s | 0.0020s | **1.111×** | ok |
| `matmul_blocked` | 0.0087s | 0.0112s | **1.287×** | ok |

Dashboard ingest still stale (09:25Z CI host `11ef5e37`); local `matmul_naive` within 1.2× cap.

## Root cause — `matmul_blocked`

C oracle uses **`static`** 512² buffers (`matmul_blocked_core.c`). Pure-Li drivers allocate **~6 MiB on the stack** each run; init uses LUT if-chains vs C `(i+j)%17 * 0.01`. Remaining ~20–25% gap is **codegen/storage**, not wrong numerics.

## Root cause — `matmul_naive`

MIR `mm_naive_256` + FMA IKJ is near cap; yellow on dashboard is **~3%** over 1.2× on ingest host (`11ef5e37` CSV). Local runs sometimes **≤1.2×** (variance).

## Quality table

| Axis | Before (briefing) | After (dashboard 09:25Z) | This pass |
|------|-------------------|--------------------------|-----------|
| **Speed** reds | 6 tier-1 | **0** | 2 yellow matmul |
| **Accuracy** | — | verify ok | unchanged |
| **Stability** | — | tier-0 skip | not touched |

## Deferred

- **lic:** BSS/global hoist for `array[N,N,float]` with N≥512 (match C `static` parity).
- **lic:** Phase 2i int→float init to drop LUT call overhead in matmul drivers.
- **benchmarks:** full tier-1 CI ingest after next lic perf PR (no hand-edit `summary.json`).
- **`ml_*` briefing reds:** stub timings — **li-math** real kernels, not harness tweak.

## Commands (ingest)

```bash
cd benchmarks
LIC_ROOT=../lic ./scripts/ingest/ingest-lic.sh
./scripts/benchmark-failures-report.sh
```
