# Wave D — MMO vertical `mmo_shard` (2026-05-23)

## Summary

**wave-d-26-vertical-mmo:** `li-mmo` shard composable, `mmorpg.toml` bench row, and `verticals.toml` honesty.

## Changes

- `packages/li-mmo/` — scaffold via `li-new-package`; `import_name = "mmo"`; `workload_class=stub`
- `packages/li-mmo/src/lib.li` — `mmo` profile shard tick + PH-MMO zone handoff stub
- `li-tests/composable/import_mmo_shard.li` — shard composable
- `benchmarks/competitive/mmorpg.toml` — `mmo_shard` composable bench row
- `benchmarks/competitive/verticals.toml` — new `mmo_shard` row
- `scripts/check-mmorpg-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/ecosystem/vertical-algorithm-catalog.md` — mmo_shard section

## Plan

Marks `wave-d-26-vertical-mmo` on compiler-studio plan loop.
