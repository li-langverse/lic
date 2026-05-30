# Study: tier-1 matmul yellow rows — bench_improver pass 2

**Date:** 2026-05-30 · **Agent:** bench_improver · **PH:** PH-5b, PH-7e · **north_star_fit:** blazingly-fast numerics (tier-1 ≤1.2× cpp advisory)

## Problem

Ingested dashboard (2026-05-30T09:25Z) shows **RED: none**; remaining tier-1 gaps:

| benchmark | ratio vs cpp | status |
|-----------|--------------|--------|
| `matmul_blocked` | 1.244× | yellow |
| `matmul_naive` | 1.222× | yellow |

Prior commit `66662a2b` used 64³×512 tiled Li workload (≠ C 512³ oracle) — **reverted** (dishonest flop label vs memory traffic).

## SOTA / learned from

| Source | Takeaway |
|--------|----------|
| Goto & van de Geijn (BLIS) | BK=64 blocked IKJ matches `matmul_blocked_core.c` |
| Org oracle `matmul_blocked_core.c` | `static` 512² buffers; modulo init |
| LLVM `llvm.fmuladd` + 4-wide `j` | `emit_matmul2d_blocked_ijk` |
| Prior study `2026-05-30-bench-improver-yellow-matmul.md` | MIR `mm_blocked_512` / `mm_naive_256` hooks |

## Changes (lic)

1. **`matmul_blocked/li/main.li`** — restore 512³ `mm_blocked_512`; drop redundant LUT init (codegen `emit_matmul_oracle_init_2d`).
2. **`compiler/codegen/emit.cpp`** — tier-1 matrices ≥512² elements → BSS `InternalLinkage` globals (C `static` parity).
3. **`benchmarks/harness/bench.py`** — `TimingStats.mean` in verify DCE guard (`TypeError` fix).

## Quality table

| Axis | Before (dashboard) | After (local, n=10) |
|------|---------------------|---------------------|
| **Speed** `matmul_naive` | 1.222× | **1.167×** (green) |
| **Speed** `matmul_blocked` | 1.244× | **1.218×** (yellow, −2.1%) |
| **Accuracy** | verify ok | unchanged (`1288460.7563999966`) |
| **Stability** | tier-0 skip | not touched |

## Commands

```bash
./scripts/build.sh
export LIC=$PWD/build/compiler/lic/lic
python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 10
LI_TIER1_PERF_STRICT=0 ./scripts/check-tier1-li-vs-cpp.sh
```

## Before/after CSV (lic harness, this host)

| benchmark | lang | wall_time (s) | ratio |
|-----------|------|---------------|-------|
| matmul_naive | cpp | 0.0018 | — |
| matmul_naive | li | 0.0021 | 1.167× |
| matmul_blocked | cpp | 0.0087 | — |
| matmul_blocked | li | 0.0106 | 1.218× |

## Deferred

- `matmul_blocked` ≤1.2× — needs full BSS hoist policy in codegen + ingest on CI runner.
- `ml_*` briefing reds — `li-math` kernels, not harness tweaks.
- **benchmarks** ingest after lic PR merge (no hand-edit `summary.json`).
