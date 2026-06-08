# Tier-2 `pure_li` parallel migration matrix

**Issue:** [#15](https://github.com/li-langverse/lic/issues/15)  
**Catalog:** [tooling-catalog.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/tooling-catalog.md)  
**Policy:** Do **not** relabel `shared_c_kernel` → `pure_li` until [REQ-PAR-PORT-3](../superpowers/plans/2026-06-08-ph7e-gpar-kokkos-class-portable-parallel-lowering-15.md) is met for that row.

## Snapshot (2026-06-08)

| Metric | Value | Source |
|--------|-------|--------|
| Tier-2 rows (local explorer) | 25 | implementation-gaps-agent 2026-05-17 |
| `pure_li` variants | 1 | explorer digest |
| `shared_c_kernel` variants | 9 | issue #15 body |
| OpenMP column | partial | no first-class Li `@` → OpenMP IR path (#34) |

## Migration gate (per row)

A row may move to **`pure_li`** only when **all** hold:

1. Kernel source uses `@cpu` / `@parallel(disjoint=…)` (or `parallel for`) — no `LI_EXTRA_C` for the Li label.
2. `lic verify` reports `mir_parallel_disjoint=1` where parallel is used.
3. Tier-2 checksum / verify smoke passes in **benchmarks** harness.
4. OpenMP scaling column (if present) uses honest IR path post-#34 or is marked `planned`.

## Recommended first row

| Row | Rationale | Depends |
|-----|-----------|---------|
| `heat_equation_2d` | Suggested in [#110](https://github.com/li-langverse/lic/issues/110); stencil + parallel_for shaped | #15 B–D, #110 View stub |

## Rows blocked on `shared_c_kernel` (inventory placeholder)

Implementation agent fills this table from **benchmarks** catalog export:

| Bench id | Current variant | Blocker | Target decorator stack |
|----------|-----------------|---------|------------------------|
| *(TBD)* | `shared_c_kernel` | C kernel / missing elaboration | `@cpu` `@parallel(disjoint=…)` |
| … | … | … | … |

**Coordination:** catalog label changes land in **benchmarks** PRs only; **lic** owns codegen + this matrix.

## Non-goals

- Weakening `threshold_ratio_cpp` to green incomplete kernels.
- Claiming Kokkos parity in catalog prose before rubric rows exist.
