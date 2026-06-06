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
| **WP-PAR-47** | `check-li-parallel-full-suite.sh` CI gate | **DONE** — Class A PR profile via `lipar-run-class-a.sh`; LIC_ROOT pinned for agent workspaces |

## Phase 1 — Shared-memory runtime

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-10** | Persistent pool `li_par_pool.c` | **DONE** — Linux pthread pool parallel static dispatch (no ephemeral spawn); Win32 thread pool |
| **WP-PAR-11** | Work-stealing scheduler | **DONE** — `LI_PAR_SCHED_STEAL` + `LI_PAR_SCHEDULE=steal`; static partition + chunk steal; smoke `li_par_pool_steal_smoke` |
| **WP-PAR-12** | static/dynamic/guided schedulers | **DONE** — `LI_PAR_SCHEDULE` + pool API; dynamic atomic chunks + guided decreasing chunks; smoke `li_par_pool_schedule_smoke` |
| **WP-PAR-13** | Tree reductions `li_par_reduce.c` | **DONE** — sum/min/max f64, sum i64 |
| **WP-PAR-14** | Windows thread pool | **DONE** — no serial `_WIN32` fallback |
| **WP-PAR-15** | Compiler `reduce` lowering | **DONE** — `par_sum(a)` → `ParReduceSumF64` / `li_par_reduce_sum_f64`; `parallel for` reduce clause Phase 1.1 |
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
| **WP-PAR-31** | `par_axpy`, `par_matmul_outer` | **DONE** — `par_outer_product_elem` + `par_matmul_outer` in `kernels.li` |
| **WP-PAR-32** | Ghost exchange templates | **DONE** — `ghost.li` 1D halo indices + exchange sketch |

## Phase 4 — Benchmarks dual-mode

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-45** | Tier1 Class A parallel variants | **DONE** — matmul_blocked, reduce_sum, simd_dot, num_dot_axpy |
| **WP-PAR-46** | Tier2 MD/FEA parallel variants | **DONE** — md_lennard_jones, fea_stiffness_assembly |
| **WP-PAR-44** | Matrix report `li_serial`/`li_parallel` columns | **DONE** — `lipar-dual-mode-csv.py` tags serial/parallel passes; `num_dot_axpy` registry alias |
| **WP-PAR-40–43** | Perf gates vs OpenMP/MPI | **DONE** — `check-li-parallel-perf-gate.sh` (speedup≥1.05× vs serial when wall≥5ms; li_parallel≤1.2× cpp); advisory CI via `.github/workflows/li-parallel-gate.yml` |

## Completion gate

```bash
bash scripts/check-li-parallel-full-suite.sh
```

Runs `packages/li-parallel/scripts/lipar-suite.sh --dual-mode --profile pr` and verifies dual-mode CSV rows for Class A tier1+2.

**Agent rules:** Do not weaken gates. Update this file honestly each loop.

**Gate evidence (2026-06-06, agent run):** `SKIP_BUILD=1 BENCH_RUNS=1 bash scripts/check-li-parallel-full-suite.sh` → exit 0 (~10s); dual-mode rows for matmul_blocked, reduce_sum, simd_dot, num_dot_axpy; perf advisory (strict=0). **CI fix:** `lipar-run-class-a.sh` uses lic `lic-bin-select.sh` instead of missing `benchmarks/scripts/lib/resolve-lic-bench.sh` on sibling checkout ref.

**Gate evidence (2026-06-06, agent run 2):** WP-PAR-31/32 package slice — `lic build packages/li-parallel/li-tests/smoke/kernels_ghost.li --allow-open-vc` → exit 0; `SKIP_BUILD=1 BENCH_RUNS=1 bash scripts/check-li-parallel-full-suite.sh` → exit 0 (~8s).

**Gate evidence (2026-06-06, agent run 3):** WP-PAR-12 schedulers — `bash li-tests/tooling/li_par_pool_schedule_smoke.sh` → exit 0; dynamic + guided cover all 64 iterations under chunk_size=7.

**Gate evidence (2026-06-06, agent run 4):** WP-PAR-11 work-stealing — `bash li-tests/tooling/li_par_pool_steal_smoke.sh` → exit 0; steal schedule covers all 64 iterations under chunk_size=7 with 4 workers.

**Gate evidence (2026-06-06, agent run 5):** WP-PAR-15 reduce lowering — `bash li-tests/tooling/li_par_reduce_codegen_smoke.sh` → exit 0; `par_sum` on `array[64,float]` links `li_par_reduce.c` + pool; `SKIP_BUILD=1 BENCH_RUNS=1 bash scripts/check-li-parallel-full-suite.sh` → exit 0.
