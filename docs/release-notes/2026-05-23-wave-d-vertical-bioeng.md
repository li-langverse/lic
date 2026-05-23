# Wave D — bioeng vertical `bio_litl` (2026-05-23)

## Summary

**wave-d-22-vertical-bioeng:** `li-bioeng` LITL/DBTL workflow composable, `bioengineering.toml` bench row, and `verticals.toml` honesty cross-links.

## Changes

- `packages/li-bioeng/` — scaffold via `li-new-package`; `import_name = "bioeng"`; `workload_class=stub`
- `packages/li-bioeng/src/lib.li` — DBTL stage state machine + assay score witness
- `li-tests/composable/import_bioeng_litl_workflow.li` — LITL workflow composable
- `benchmarks/competitive/bioengineering.toml` — `bio_litl` composable bench row
- `benchmarks/competitive/verticals.toml` — new `bio_litl` row
- `scripts/check-bioengineering-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/ecosystem/vertical-algorithm-catalog.md` — bio_litl bench/composable citations

## Plan

Marks `wave-d-22-vertical-bioeng` on compiler-studio plan loop.
