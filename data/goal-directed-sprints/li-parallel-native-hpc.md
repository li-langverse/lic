# li-parallel — Native Parallel + Distributed HPC (goal-directed sprint)

**Repos:** `lic` (primary), `benchmarks`, `li-cursor-agents  
**Branch:** `cursor/li-parallel-native-hpc`  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `LOOP_MAX=0` until gate passes)

## Mission

Build **li-parallel** — zero-install OpenMP/MPI replacement: persistent thread pool, reductions, TCP distributed runtime, full org benchmark suite dual-mode (`li_serial` + `li_parallel`).

## Phase 0 — Foundation

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-00** | Spec `docs/superpowers/specs/2026-06-06-li-parallel-design.md` + G-par-dist row | **DONE** — spec committed |
| **WP-PAR-01** | Package `packages/li-parallel/` + workspace member | **DONE** — scaffold + import `parallel` |
| **WP-PAR-02** | `lipar-suite.sh` wraps `run-full-benchmark-suite.sh` | **DONE** — serial + parallel passes |
| **WP-PAR-47** | `check-li-parallel-full-suite.sh` CI gate | **DONE** — dual-mode tier1 Class A rows + linker fix |

## Phase 1 — Shared-memory runtime

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-10** | Persistent pool `li_par_pool.c` | **DONE** — replaces pthread spawn; Win32 thread pool |
| **WP-PAR-11** | Work-stealing scheduler | **STUB** — static chunks via pool; steal in Phase 1.1 |
| **WP-PAR-12** | static/dynamic/guided schedulers | **STUB** — static only in v1 slice |
| **WP-PAR-13** | Tree reductions `li_par_reduce.c` | **DONE** — sum/min/max f64, sum i64 |
| **WP-PAR-14** | Windows thread pool | **DONE** — no serial `_WIN32` fallback |
| **WP-PAR-15** | Compiler `reduce` lowering | **STUB** — runtime API ready; MIR lowering Phase 1.1 |
| **WP-PAR-16** | Reduction policy | **STUB** — existing G-par disjoint gates |

## Phase 2 — Distributed runtime

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-20** | TCP bootstrap `li_dpar.c` | **DONE** — env ranks + localhost mesh |
| **WP-PAR-21** | Block partition helpers | **DONE** — `li_dpar_block_partition_*` |
| **WP-PAR-22** | Collectives | **DONE** — bcast/allreduce f64/i64 ring |
| **WP-PAR-23** | `distributed for` MIR | **STUB** — runtime + package surface only |
| **WP-PAR-24** | `rank()` / `world_size()` | **DONE** — C API + package `distributed.li` |

## Phase 3 — Package API

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-30** | Proof helpers | **DONE** — `disjoint_tile`, `disjoint_block` lemmas |
| **WP-PAR-31** | `par_axpy`, `par_matmul_outer` | **DONE** — package kernels |
| **WP-PAR-32** | Ghost exchange templates | **STUB** — 1D halo sketch in package |

## Phase 4 — Benchmarks dual-mode

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-45** | Tier1 Class A parallel variants | **DONE** — matmul_blocked, reduce_sum, simd_dot, num_dot_axpy |
| **WP-PAR-46** | Tier2 MD/FEA parallel variants | **DONE** — md_lennard_jones, fea_stiffness_assembly |
| **WP-PAR-44** | Matrix report `li_serial`/`li_parallel` columns | **DONE** — `speedup_vs_serial` in report |
| **WP-PAR-40–43** | Perf gates vs OpenMP/MPI | **IN PROGRESS** — harness wired; thresholds pending CI |

## Completion gate

```bash
bash scripts/check-li-parallel-full-suite.sh
```

Runs `packages/li-parallel/scripts/lipar-suite.sh --dual-mode --profile pr` and verifies dual-mode CSV rows for Class A tier1+2.

**Agent rules:** Do not weaken gates. Update this file honestly each loop.
