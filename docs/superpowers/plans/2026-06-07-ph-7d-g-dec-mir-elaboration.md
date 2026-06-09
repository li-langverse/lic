# PH-7d / G-dec — decorator MIR elaboration (7d-b–e)

> **Issue:** [#22](https://github.com/li-langverse/lic/issues/22) · **Repo:** li-langverse/lic  
> **Vision:** provable (compile-time elaboration, no runtime registry) → easy (`@` stacks on `def`/`for`) → fast (same MIR as keywords, after proof)  
> **north_star_fit:** Scientific computing / HPC · **PH-7d** · **G-dec** (primary), **G-par** (cross-link)

**Learned from:**

1. [provability-gaps.md](../../verification/provability-gaps.md) — **G-dec** row: parse + policy + `MirFn.decorators`; MIR lowering slice landed in #22 PRs
2. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) § 7d — sub-phase table + exit gate L72–L76
3. [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md) — compile-time elaboration to `ParallelFor` / SIMD / placement tags
4. `li-tests/decorator_exploits/` + `li-tests/decorators/` — policy vs positive elaboration delta
5. `scripts/check-mir-*-decorator.sh` — MIR telemetry smokes

> **Complements (not duplicates):** [#387](https://github.com/li-langverse/lic/issues/387) — **G-par** Lean discharge + proc-tag parity; [#429](https://github.com/li-langverse/lic/issues/429) — tier-2 MD `@` on `def` workload. **#22** owns **G-dec** elaboration exit gates **7d-b–e** and Doc-c cross-links.

## Goal

Close the master-plan **Phase 7d / G-dec** gap: decorators move from **parse + policy + telemetry** to **MIR elaboration** — the same proved cores as keyword `parallel for`, scoped `@vectorized for`, and host/device placement.

Deliverables:

1. **Named exit gates** for **7d-b–e** (elaboration + `decorator_exploits` CI) in phase-07 and this plan.
2. **Cross-link** **G-dec** and **G-par** wherever disjointness still uses string heuristics in `policy_module.cpp`.
3. **`provability-gaps.md`** updated in the **same PR as behavior changes**.

## Non-goals

- Full **G-par** Lean iteration-independence proofs — **#387** (`proof_gap_researcher`).
- Tier-2 MD benchmark decorator showcase — **#429** (no `threshold_ratio_cpp` weakening).
- `@gpu` LKIR / address-space proofs — **G-gpu** (Wave 13 telemetry only today).
- `@async` structured concurrency — **G-async**.
- `trusted.lean` edits without maintainer-approved issue.
- Weakening `decorator_exploits` to advisory.

## Current state (2026-06-09)

| Sub | Asset | Status |
|-----|-------|--------|
| **7d-a** | Parse `@` on `def`/`for`/`while` | **Done** — `li-tests/decorators/*_parse_ok.li` |
| **7d-e (partial)** | Policy: reserved names, typosquat, `parallel_requires_disjoint` | **Done** — `decorator_exploits/` 4× `compile_fail` in CI |
| **7d-b (partial)** | `@cpu` / `@vectorized` / `@parallel` on `def` | `@cpu` → `mir_cpu_def=1`; proc `@vectorized` → `ArraySimdScope` (`mir_vectorized_def_scope`); `@vectorized(lanes=4)` proc tag (`mir_vectorized_proc`) |
| **7d-c (partial)** | `@vectorized` on `for` → `ArraySimdScope` | `vectorized_for_scope_ok.li` — **done** (#150) |
| **7d-c (partial)** | `@parallel(disjoint=)` on `def` → nested `parallel for` MIR | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1` |
| **7d-d (partial)** | `std/execution/decorators.li` + `docs/language/decorators.md` | Handbook stub; gallery pending |
| **7d-e (open)** | `decorator def` strict naming + expansion whitelist | Exploit corpus partial; macro expansion not wired |
| **G-dec register** | Summary table | MIR proc tags + body `ArraySimdScope` from proc `@vectorized`; macro expansion open |
| **G-par register** | Overlap | `check_module_policies` string heuristics — see **#387** |

## Sub-phases and exit gates (7d-b–e)

| Sub | Deliverable | Exit gate | G-* |
|-----|-------------|-----------|-----|
| **7d-b — Elaboration core** | `@cpu` / `@parallel` / `@vectorized` on `def` lower to host placement + proc SIMD flags in MIR | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1`; `vectorized_def_scope_ok.li` → `mir_vectorized_def_scope=1`; `cpu_only_ok.li` → `mir_cpu_def=1` | **G-dec** |
| **7d-c — Structured disjoint + scoped vectorize** | Proc `@parallel(disjoint=…)` inherits to nested loops; `@vectorized` on `for` remains scoped | `./li-tests/run_all.sh race_shared_memory decorators` green; `check-mir-parallel-decorator.sh` | **G-dec**, **G-par** (policy witnesses only until **#387** Lean) |
| **7d-d — Stdlib + handbook** | `std/execution/decorators.li` + `docs/language/decorators.md` gallery | `check-doc-provability-claims.sh` pass; no false "elaborated" claims | **G-dec** (doc honesty) |
| **7d-e — Macro surface + exploits** | `decorator def` package-prefix + typosquat ban + expansion whitelist | All exploit fixtures `compile_fail`; `./li-tests/run_all.sh decorator_exploits` in `scripts/ci.sh` | **G-dec** |

### G-par cross-link (7d-c)

Where elaboration still relies on `parallel_for_disjoint_witness(stmt, proc_decorators)` string/heuristic checks in `policy_module.cpp`, document as **G-par Partial** and link **#387** — do **not** mark **G-par Done** when only **G-dec** elaboration lands.

## Tests / benches

| Gate | Command / artifact |
|------|-------------------|
| Exploit corpus | `./li-tests/run_all.sh decorator_exploits` |
| Positive decorators | `./li-tests/run_all.sh decorators` |
| Disjoint policy | `./li-tests/run_all.sh race_shared_memory` |
| MIR smokes | `scripts/check-mir-cpu-decorator.sh`, `check-mir-parallel-decorator.sh`, `check-mir-vectorized-decorator.sh` |
| Doc gate | `scripts/check-doc-provability-claims.sh` |

## Human-only

- [ ] Review and merge implementation PR
- [ ] Route 7d-e macro expansion to **code_implementer**; Lean **G-par** to **proof_gap_researcher** via **#387**
- [ ] Close **#22** when acceptance boxes checked and CI green
