# PH-7d: Tier-2 MD benchmark with `@` decorators on `def`

> **Issue:** [#429](https://github.com/li-langverse/lic/issues/429) · **Repo:** li-langverse/lic  
> **Vision:** easy (decorator-first HPC surface), provable (MIR parity with keywords), blazingly-fast (tier-2 MD showcase) · **Learned from:** [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) § 7d, [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md), `li-tests/decorators/parallel_def_disjoint_inherit.li`, Kokkos execution-space decorator patterns (explorer #109)

## Goal

Close the open sub-plan gate: **`benchmarks/tier2_physics/md_lennard_jones/`** (or documented alternate tier-2 kernel) ships a hot-path `def` annotated with `@cpu`, `@parallel(disjoint=…)`, and `@vectorized` that elaborates to the **same MIR** as equivalent keyword forms — proving decorator-first HPC is production-shaped, not parse-only.

## Non-goals

- Full **G-par** Lean proofs (`#387`) — tracked separately
- Fuzz corpus `@` stacks (phase-07 checkbox line 76) — follow-up PR
- Rewriting entire MD kernel in math notation (7e) — decorators on existing loop structure only
- Copying harness to **benchmarks** repo — harness stays here

## Dependencies

- **PH-7d** partial (#150 7d-c: `@vectorized` on `for`)
- **PH-7b** `parallel for` + disjoint policy
- Complements **#387** (MIR proc tags + Lean)
- `catalog.toml` row `md_lennard_jones` in **benchmarks** (ingest only)

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **7d-md-1** | Refactor MD inner loop into `def step(...)` with `@cpu` `@parallel(disjoint=…)` `@vectorized` | `lic build` + bench driver compile |
| **7d-md-2** | MIR diff test or `compile_ok` + documented MIR tag equality vs keyword version | `li-tests/decorators/` or new `md_decorator_mir_ok.li` |
| **7d-md-3** | Tier-2 bench still runs green | `bench.py --tier 2 md_lennard_jones` ratio unchanged ± noise |
| **7d-md-4** | Sub-plan checkbox | [phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) L75 `[x]` in same PR |

## Tests / benches

- `li-tests/decorators/` — extend with MD-shaped `def` decorator stack
- `li-tests/decorator_exploits/` — must remain fail-closed
- Tier-2: `md_lennard_jones` (dashboard ingest via **benchmarks** `LIC_ROOT=../lic`)
- CVE row: none (no new attack surface)

## Provability

| G-* | Movement |
|-----|----------|
| **G-dec** | Partial → Partial+ (elaboration exercised on tier-2 production path; full MIR tags still open with #387) |
| **G-par** | Partial unchanged until Lean proofs land (#387) |
| Honest limit | Decorator `def` on MD does **not** close **G-par** Done |

## Rollout

1. PR: `md_lennard_jones/li/main.li` (or `stress.li` hot path) + tests
2. PR: phase-07 sub-plan checkbox + master plan 7d note if wording needs tweak
3. **benchmarks**: no catalog change; re-ingest after lic merge for dashboard honesty
4. Request **`plan-approved`** on #429 before implementation agents run
