# li-parallel gap register

<!-- DOC-PAR-12 -->

Open work packages blocking killer gate completion. Updated 2026-06-06.

## Phase 1 — Shared memory

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-15 | `team()` / program-first `reduce` | **IN PROGRESS** |
| WP-PAR-17 | Variable cores / scoped team | **PENDING** |
| WP-PAR-18 | Callable parallel defs | **PENDING** |
| WP-PAR-19 | Unlimited/auto cores | **PENDING** |

## Phase 2 — Distributed

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-20 | Programmed `hosts=[...]` cluster | **PENDING** |
| WP-PAR-22 | scatter/gather/scan/barrier | **PENDING** |

## Phase 4 — Benchmarks

| WP | Gap | Status |
|----|-----|--------|
| WP-PAR-40 | Strict perf vs OpenMP/MPI | **IN PROGRESS** |
| WP-PAR-48 | Whole-catalog dual-mode audit | **PENDING** |

## Phase 6–8 — FL, comm, hetero, xfer

| WP range | Gap | Status |
|----------|-----|--------|
| WP-PAR-60–65 | Federated learning hardening | **PENDING** |
| WP-PAR-70–75 | Compiler comm plan | **PENDING** |
| WP-PAR-07–09 | Embedded execution plan | **IN PROGRESS** — team/cluster/offload/overlap comm compile smokes land; runtime plan apply at main |
| WP-PAR-79–86 | Chip packages + boundaries | **PENDING** |
| WP-PAR-87–92 | Transfer plan | **PENDING** |

## Documentation (this sprint)

| WP | Deliverable | Status |
|----|-------------|--------|
| WP-PAR-50 | Handbook chapter | **DONE** |
| WP-PAR-51 | API reference | **DONE** |
| WP-PAR-52 | Migration guides | **DONE** |
| WP-PAR-53 | Examples corpus | **DONE** |
| WP-PAR-54 | mkdocs nav manifest | **DONE** |
| WP-PAR-55 | Gap register | **DONE** |

## Proof gaps

| Gap | Status |
|-----|--------|
| G-par | Partial |
| G-par-dist | Closed slice |
| G-hetero | Pending |

See [proofs table](proofs-table.md) and [provability gaps](../../../docs/verification/provability-gaps.md).
