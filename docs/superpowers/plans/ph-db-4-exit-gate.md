# PH-DB-4 exit gate — central registry DB (unblocks PH-8d-v2)

**Status:** In progress (WP-D MVP landed on lidb)  
**Battle plan:** [ph-db-battle-plan.md](./ph-db-battle-plan.md) § WP-D  
**Hard rule:** Do **not** ship **PH-8d-v2** (lip remote registry v2) until every **blocking** item below is checked.

## Gate checklist

| # | Criterion | Owner | Status (2026-05-26) |
|---|-----------|-------|---------------------|
| G1 | `lidb/migrations/001_registry.sql` applied via native embed (`lidb_embed migrate`) | lidb | **Done** (smoke + pytest) |
| G2 | Registry OLTP reads/writes via `liorm` (not stub/mock) | lidb | **Done** — `registry/RegistryOltp` |
| G3 | Read-path OpenAPI field parity = zero blockers | lip + lidb | **Partial** — see [gap table](https://github.com/li-langverse/lidb/blob/main/docs/ph-db-4-registry-gap.md) |
| G4 | Publish-path columns (`manifest_signature`, `source_*`) migrated or explicitly deferred with ADR | lidb | **Not done** |
| G5 | lip OpenAPI merged from `feat/ph-db-4-registry-openapi`; PRs labeled until G3–G4 green | lip | **Blocked** — branch exists, not on `main` |
| G6 | `002_rls_registry.sql` design reviewed; enforcement tested (not necessarily enabled in registry-min) | lidb | **Design only** |
| G7 | `lis db` registry-min profile operational (PH-DB-3) | lis | **Not done** (recommended) |
| G8 | Human sign-off recorded in release notes / master plan | human | **Pending** |

## PH-8d-v2 readiness estimate

| Area | Weight | Progress |
|------|--------|----------|
| Schema on lidb (`001`) | 25% | 100% |
| OLTP service (read + publish MVP) | 25% | 85% |
| lip OpenAPI + HTTP handlers | 30% | 15% (spec branch only) |
| RLS + ops (`lis db`) | 10% | 20% |
| Sign-off + bench parity | 10% | 0% |

**Approximate unblock:** **~55%** after WP-D MVP (G1–G2); **~85%** after G3–G5 + G7; **100%** requires G8.

## lip PR policy

Until this gate is **Passed**:

- Label lip registry HTTP PRs **`blocked-on-PH-DB-4`**
- Do not enable remote registry v2 in production docs or default `lip` config

## References

| Doc | Location |
|-----|----------|
| Gap table | [lidb/docs/ph-db-4-registry-gap.md](https://github.com/li-langverse/lidb/blob/main/docs/ph-db-4-registry-gap.md) |
| Phase index | [ph-db-lidb-platform.md](./ph-db-lidb-platform.md) |
| Tier bench DDL | [tier-db-registry-benchmark.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/tier-db-registry-benchmark.md) |
