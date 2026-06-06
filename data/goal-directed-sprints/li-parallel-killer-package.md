# li-parallel killer package — goal-directed sprint

**Repos:** `lic` (primary), `benchmarks`, `li-cursor-agents  
**Branch:** `cursor/li-parallel-native-hpc`  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `LOOP_MAX=0`)

## Mission

Ship **li-parallel** — the native Li OpenMP/MPI replacement with program-first parallelism, unlimited cores, full distributed + FL + comm/xfer plans, CPU+GPU+TPU+ASIC hetero via uniform chip packages (`li-gpu`, `li-tpu`, `li-asic`), and **whole org benchmark suite** dual-mode (`li_serial` + `li_parallel`).

**Do not weaken gates.** Update phase tables honestly each loop. `GOAL_COMPLETE` requires all phases **DONE** and the killer gate green.

## Progress gate

```bash
bash scripts/check-li-parallel-full-suite.sh
```

Fast PR slice: Class A tier1+2 dual-mode rows + advisory perf.

## Completion gate

```bash
bash scripts/check-li-parallel-killer-gate.sh
```

Whole stack: runtime smokes, sub-gates (docs, distributed, FL, comm, hetero, xfer, proofs, chip boundaries), **full** `run-full-benchmark-suite.sh` dual-mode (tiers 0–7). **No** `LIPAR_KILLER_SKIP_FULL`.

---

### Phase 0 — Program-first foundation

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-00** | Design spec + G-par-dist row | **DONE** |
| **WP-PAR-01** | Package scaffold `packages/li-parallel/` | **DONE** |
| **WP-PAR-02** | `lipar-suite.sh` wraps `run-full-benchmark-suite.sh` | **IN PROGRESS** — PR profile only; whole-catalog pending WP-PAR-48 |

### Phase 1 — Shared-memory runtime

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-10** | Persistent pool `li_par_pool.c` | **DONE** |
| **WP-PAR-11** | Work-stealing scheduler | **DONE** |
| **WP-PAR-12** | static/dynamic/guided schedulers | **DONE** |
| **WP-PAR-13** | Tree reductions | **DONE** |
| **WP-PAR-14** | Windows thread pool | **DONE** |
| **WP-PAR-15** | Compiler `reduce` lowering | **IN PROGRESS** — `par_sum` + `parallel for reduce`; program-first `team()` pending WP-PAR-07–09 |
| **WP-PAR-16** | Reduction policy proofs | **DONE** |
| **WP-PAR-17** | Variable cores / scoped team push-pop | **PENDING** |
| **WP-PAR-18** | Callable parallel defs | **PENDING** |
| **WP-PAR-19** | Unlimited/auto cores; drop LI_MAX_THREADS cap | **PENDING** |

### Phase 2 — Distributed runtime

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-20** | TCP bootstrap `li_dpar.c` | **DONE** — programmed cluster via lipar-run + exec plan |
| **WP-PAR-21** | Block partition helpers | **DONE** |
| **WP-PAR-22** | Collectives | **DONE** — scatter/gather/scan/barrier + MD weak-scaling smoke |
| **WP-PAR-23** | `distributed for` MIR | **DONE** |
| **WP-PAR-24** | `rank()` / `world_size()` | **DONE** |

### Phase 3 — Package API

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-30** | Proof helpers | **IN PROGRESS** — disjoint lemmas; G-par-dist/G-hetero register pending |
| **WP-PAR-31** | `par_axpy`, `par_matmul_outer` | **DONE** |
| **WP-PAR-32** | Ghost exchange templates | **DONE** — sketch only |

### Phase 4 — Benchmarks dual-mode

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-45** | Tier1 Class A parallel variants | **DONE** — matmul_blocked, reduce_sum, simd_dot, num_dot_axpy |
| **WP-PAR-46** | Tier2 MD/FEA parallel variants | **DONE** — md_lennard_jones, fea_stiffness_assembly |
| **WP-PAR-44** | Matrix `li_serial`/`li_parallel` columns | **DONE** |
| **WP-PAR-40** | Perf gates vs OpenMP/MPI | **IN PROGRESS** — advisory in CI; strict killer gate pending |
| **WP-PAR-47** | PR gate `check-li-parallel-full-suite.sh` | **DONE** |
| **WP-PAR-48** | Whole-catalog dual-mode audit | **PENDING** |

### Phase 5 — Documentation

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-50** | Handbook chapter | **DONE** |
| **WP-PAR-51** | API reference | **DONE** |
| **WP-PAR-52** | OpenMP/MPI migration guide | **DONE** |
| **WP-PAR-53** | Examples corpus | **DONE** |
| **WP-PAR-54** | mkdocs nav (DOC-PAR-01–14) | **DONE** |
| **WP-PAR-55** | Gap register | **DONE** |

### Phase 6 — Federated learning hardening

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-60** | Partial rank participation | **PENDING** |
| **WP-PAR-61** | Straggler mitigation | **PENDING** |
| **WP-PAR-62** | Compressed halos | **PENDING** |
| **WP-PAR-63** | Hetero ranks | **PENDING** |
| **WP-PAR-64** | Comm/compute overlap (FL) | **PENDING** |
| **WP-PAR-65** | Fault tolerance / shrink | **PENDING** |

### Phase 7 — Compiler comm plan

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-70** | Embedded `__li_comm_plan` | **PENDING** |
| **WP-PAR-71** | `overlap comm` MIR | **PENDING** |
| **WP-PAR-72** | Ghost overlap ≥50% MD specimen | **PENDING** |
| **WP-PAR-73** | RDMA hooks | **PENDING** |
| **WP-PAR-74** | Latency benchmarks | **PENDING** |
| **WP-PAR-75** | Compressed halo bench | **PENDING** |

### Phase 8 — Heterogeneous orchestration

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-07** | Embedded execution plan | **IN PROGRESS** — `__li_exec_plan` global + `li_exec_plan_apply` at main |
| **WP-PAR-08** | `team()` / `cluster()` parser | **IN PROGRESS** — compile smokes green; scoped push/pop v1 |
| **WP-PAR-09** | Runtime reads compiled plan at main | **IN PROGRESS** — `li_exec_plan_apply` reads embedded plan |
| **WP-PAR-79** | Rename `lig` → `li-gpu` (`import ligpu`) | **PENDING** |
| **WP-PAR-80** | Hetero orchestration API in li-parallel | **PENDING** |
| **WP-PAR-83** | New `li-tpu` (`import litpu`) | **PENDING** |
| **WP-PAR-84** | New `li-asic` (`import liasic`) | **PENDING** |
| **WP-PAR-86** | `check-chip-package-boundaries.sh` | **PENDING** |

### Phase 8b — Transfer plan

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-87** | Embedded `__li_xfer_plan` | **PENDING** |
| **WP-PAR-88** | Copy elision | **PENDING** |
| **WP-PAR-89** | Fusion | **PENDING** |
| **WP-PAR-90** | D2D paths | **PENDING** |
| **WP-PAR-91** | RDMA→GPU | **PENDING** |
| **WP-PAR-92** | Dashboard `xfer_sec` / `elided_copies` | **PENDING** |

### Phase 99 — Killer gate

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-99** | `check-li-parallel-killer-gate.sh` | **IN PROGRESS** — hardened; sub-gates fail until WPs above land |

## Agent rules

1. Work highest-impact pending WP toward killer gate failure messages.
2. Never add `LIPAR_KILLER_SKIP_FULL` or tier skips to pass the gate.
3. Chip drivers live only in `li-gpu` / `li-tpu` / `li-asic`; li-parallel orchestrates; li-ml has algorithms only.
4. Mark a phase **DONE** only when its WPs are implemented **and** the relevant sub-gate passes.
5. Run progress gate each loop; run killer gate before marking Phase 99 **DONE**.

## Current blocker (2026-06-06)

Killer gate advances past `check-li-parallel-compile-smoke-gate.sh` (WP-PAR-07–09 compile slice landed). Next blocker: `audit-li-parallel-catalog-coverage.sh` / distributed / comm sub-gates until remaining WPs land.
