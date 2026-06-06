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
| **WP-PAR-17** | Variable cores / scoped team push-pop | **IN PROGRESS** — push/pop stack + scope smoke |
| **WP-PAR-18** | Callable parallel defs | **DONE** — `@parallel` defs callable with `var array` + parallel-for capture |
| **WP-PAR-19** | Unlimited/auto cores; drop LI_MAX_THREADS cap | **IN PROGRESS** — `team(cores=0)`, cap 256, env `LI_MAX_THREADS` |

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
| **WP-PAR-30** | Proof helpers | **DONE** — G-par-dist + G-hetero closed slices in provability register |
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
| **WP-PAR-48** | Whole-catalog dual-mode audit | **IN PROGRESS** — `--scope all` CSV tagging + Li-only killer gate check |

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
| **WP-PAR-60** | Partial rank participation | **DONE** |
| **WP-PAR-61** | Straggler mitigation | **DONE** |
| **WP-PAR-62** | Compressed halos | **DONE** |
| **WP-PAR-63** | Hetero ranks | **DONE** |
| **WP-PAR-64** | Comm/compute overlap (FL) | **DONE** |
| **WP-PAR-65** | Fault tolerance / shrink | **DONE** |

### Phase 7 — Compiler comm plan

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-70** | Embedded `__li_comm_plan` | **DONE** |
| **WP-PAR-71** | `overlap comm` MIR | **DONE** |
| **WP-PAR-72** | Ghost overlap ≥50% MD specimen | **DONE** |
| **WP-PAR-73** | RDMA hooks | **DONE** — stub registration + smoke |
| **WP-PAR-74** | Latency benchmarks | **DONE** — barrier RTT bench |
| **WP-PAR-75** | Compressed halo bench | **DONE** |

### Phase 8 — Heterogeneous orchestration

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-07** | Embedded execution plan | **IN PROGRESS** — team/cluster/offload/overlap comm compile smokes green; runtime plan apply at main |
| **WP-PAR-08** | `team()` / `cluster()` parser | **IN PROGRESS** — compile smokes green; scoped push/pop v1 |
| **WP-PAR-09** | Runtime reads compiled plan at main | **IN PROGRESS** — `li_exec_plan_apply` reads embedded plan |
| **WP-PAR-79** | Rename `lig` → `li-gpu` (`import ligpu`) | **DONE** |
| **WP-PAR-80** | Hetero orchestration API in li-parallel | **DONE** |
| **WP-PAR-83** | New `li-tpu` (`import litpu`) | **DONE** |
| **WP-PAR-84** | New `li-asic` (`import liasic`) | **DONE** |
| **WP-PAR-86** | `check-chip-package-boundaries.sh` | **DONE** |
| **WP-PAR-86** | `check-chip-package-boundaries.sh` | **PENDING** |

### Phase 8b — Transfer plan

| WP | Deliverable | Status |
|----|-------------|--------|
| **WP-PAR-87** | Embedded `__li_xfer_plan` | **DONE** |
| **WP-PAR-88** | Copy elision | **DONE** |
| **WP-PAR-89** | Fusion | **DONE** |
| **WP-PAR-90** | D2D paths | **DONE** |
| **WP-PAR-91** | RDMA→GPU | **DONE** |
| **WP-PAR-92** | Dashboard `xfer_sec` / `elided_copies` | **DONE** |

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

Killer gate advances past `check-li-parallel-xfer-gate.sh` (WP-PAR-87–92 transfer plan). Next blockers: remaining IN PROGRESS WPs (WP-PAR-02, WP-PAR-15, WP-PAR-30, WP-PAR-40, WP-PAR-48, WP-PAR-07–09) and killer gate full-suite breadth.
