# PH-7d: Tier-2 MD benchmark with `@` decorators on `def`

> **Issue:** [#429](https://github.com/li-langverse/lic/issues/429) · **Repo:** li-langverse/lic (plan) + li-langverse/benchmarks (workload)  
> **Vision:** easy (decorator-first HPC surface) → provable (MIR parity with keywords) → fast (tier-2 MD showcase, after proof)  
> **north_star_fit:** Scientific computing / HPC · **PH-7d**, **PH-5b** (validity), **G-dec**, **G-par** (partial)

**Learned from:**

1. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) § 7d exit gate (L75)
2. [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md) — compile-time elaboration, no runtime registry
3. `li-tests/decorators/parallel_def_disjoint_inherit.li` — `@cpu` + `@parallel(disjoint=)` on `def` pattern
4. `benchmarks/workloads/tier2_physics/md_lennard_jones/` (benchmarks repo) — current thin `LI_EXTRA_C` driver; workloads migrated per `benchmarks/README.md`

## Goal

Close the open sub-plan gate in phase-07:

> Tier 2 MD example uses `@cpu` `@parallel` `@vectorized` on `def` (elaborates to same MIR as keywords)

Ship a **production-shaped** tier-2 MD hot path where the inner force/integration kernel is a `def` annotated with `@cpu`, `@parallel(disjoint=…)`, and `@vectorized` — not parse-only decorator tests.

## Non-goals

- Full **G-par** Lean discharge (**#387**) — MIR proc tags + Lean proofs tracked separately
- Weakening `threshold_ratio_cpp` (1.2) on `md_lennard_jones` to make a slow pure-Li path green
- `trusted.lean` edits — human-approved issues only
- Fuzz corpus `@` decorator stacks (phase-07 L76) — follow-up after this gate
- Rewriting full MD stack in math notation (**PH-7e**) — decorators on existing loop structure only
- Catalog-only ingest change in **benchmarks** without Li kernel source

## Current state (2026-06-07)

| Asset | Status |
|-------|--------|
| Decorator parse/policy | `li-tests/decorators/`, `decorator_exploits/` green |
| `@vectorized` on `def` | `vectorized_dot_proc_ok.li`, `vectorized_dot_ok.li` — `compile_ok` only |
| `@parallel(disjoint=)` on `def` | `parallel_def_disjoint_inherit.li` — `compile_ok` only |
| Tier-2 `md_lennard_jones` Li driver | `benchmarks/.../md_lennard_jones/li/main.li` — **extern C** via `LI_EXTRA_C`; **no `@` on `def`** |
| Phase-07 L75 checkbox | **Open** |
| MIR proc-tag equality test | **Open** — blocked on **#387** partial |

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-7d** | Parent phase; 7d-a/e partial on `main` |
| **PH-7b** | `parallel for` + disjoint policy (keyword path) |
| **PH-5b** | Tier-2 checksum / validity harness |
| **#387** | MIR proc tags + **G-par** Lean — complements; not blocking decorator landing |
| **benchmarks** `catalog.toml` | `md_lennard_jones` row `repo = "lic"`, `path = benchmarks/workloads/tier2_physics/md_lennard_jones` |

## Plan home

- **This file** — scoped implementation plan (lic)
- **Workload edits** — `li-langverse/benchmarks` PR (paired with lic implementation PR)
- **Master plan** — checkbox L75 in [phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md); no new PH id

## Sub-phases

| Sub | Repo | Deliverable | Exit gate |
|-----|------|-------------|-----------|
| **A — Spec** | lic | Document target `def` signature, `disjoint=` predicate, and keyword-equivalent sketch | Plan approved (this doc) |
| **B — Kernel** | benchmarks | Add `li/kernel.li`: `def lj_force_step(...)` (or `lj_integrate_step`) with `@cpu` `@parallel(disjoint=disjoint_atom_i)` `@vectorized(lanes=4)` on the hot `def` | `lic build` on workload path |
| **C — Driver** | benchmarks | `li/main.li` calls decorator `def`; retain C oracle (`md_core.c`) for checksum cross-check smoke until pure-Li parity proven | `catalog_smoke.py md_lennard_jones` green |
| **D — MIR parity** | lic | `li-tests/decorators/md_lj_decorator_def_ok.li` (MD-shaped miniature) + MIR tag script or documented delta vs keyword `parallel for` | `run_all.sh decorators` green; delta doc if #387 open |
| **E — Phase gate** | lic | Check phase-07 L75 `[x]`; note in `provability-gaps.md` **G-dec** slice | Same implementation PR as B–D |
| **F — Bench honesty** | benchmarks | Do **not** lower `threshold_ratio_cpp`. If pure-Li perf > 1.2× cpp: keep published tier-2 row on shared-C path **or** mark Li row advisory until PH-7e; decorator path verified via tier-0 / checksum smoke | No threshold weakening |

### Target kernel shape (sketch)

Mirror `parallel_def_disjoint_inherit.li` on MD SoA layout:

```li
@cpu
@parallel(disjoint=disjoint_atom_i)
@vectorized(lanes=4)
def lj_force_step(
  pos: array[N, f64, 3],
  force: array[N, f64, 3],
  ...
) -> unit
  requires ...
  ensures ...
=
  parallel for i in 0..<N
    ...
```

Keyword-equivalent reference: same loop body with `parallel for` + inner SIMD-friendly pair loop (no decorators) for MIR diff in sub-phase D.

**Alternate tier-2 kernel:** If full LJ refactor risks PH-5b regression, document `md_neighbor_cell_list` or a new `md_lennard_jones/li/decorator_showcase.li` entry point — but **prefer** in-place `md_lennard_jones` per issue acceptance.

## PH / REQ / G-* mapping

| ID | Movement |
|----|----------|
| **PH-7d** | Partial → Partial+ (tier-2 production path exercises decorator `def` elaboration) |
| **PH-5b** | Unchanged — checksum smoke must stay green |
| **REQ-7d-decorator-def** | Tier-2 MD `def` carries full execution decorator stack |
| **REQ-7d-mir-parity** | Decorator elaboration matches keyword MIR (or documented delta + test) |
| **G-dec** | Partial → Partial+ (elaboration on tier-2 path; Lean **P-dec** still open) |
| **G-par** | **Partial unchanged** until **#387** Lean disjoint proofs land |

**Honest limit:** Closing L75 does **not** mark **G-par** Done.

## Tests / benches

| Gate | Command / artifact |
|------|-------------------|
| Decorator regressions | `./li-tests/run_all.sh decorators decorator_exploits` |
| MD-shaped decorator test | `li-tests/decorators/md_lj_decorator_def_ok.li` (new) |
| Tier-0 / catalog smoke | `benchmarks/harness/catalog_smoke.py` + `bench.py --tier 0 --only md_lennard_jones` |
| Tier-2 advisory | `bench.py --tier 2 --only md_lennard_jones` — ratio check; no threshold edit |
| CVE | None — no new attack surface |

## Rollout (implementation PRs, post-`plan-approved`)

1. **benchmarks PR:** `li/kernel.li` + `main.li` wiring + smoke notes in `PERF.md`
2. **lic PR:** `li-tests/decorators/md_lj_decorator_def_ok.li`, phase-07 L75, `provability-gaps.md` **G-dec** note
3. Re-ingest dashboard after both merge (`LIC_ROOT` + `BENCHMARKS_ROOT`)
4. Close **#429** when acceptance boxes checked

## Vision checks

| Check | Result |
|-------|--------|
| Proof-before-perf | Yes — MIR parity + disjoint policy before perf claims |
| Strict-by-default | Yes — `decorator_exploits` remain fail-closed |
| Benchmark threshold gaming | **Rejected** — no `threshold_ratio_cpp` weakening |
| New org repo | Not needed |
| `trusted.lean` | Out of scope |

## Human-only

- [ ] Review and merge this plan PR
- [ ] Add label **`plan-approved`** on [#429](https://github.com/li-langverse/lic/issues/429)
- [ ] Remove **`plan-needed`** after ack
- [ ] Route to **code_implementer** for sub-phases B–F
