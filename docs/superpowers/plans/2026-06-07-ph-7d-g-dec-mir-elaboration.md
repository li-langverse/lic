# PH-7d / G-dec — decorator MIR elaboration (7d-b–e)

> **Issue:** [#22](https://github.com/li-langverse/lic/issues/22) · **Repo:** li-langverse/lic  
> **Vision:** provable (compile-time elaboration, no runtime registry) → easy (`@` stacks on `def`/`for`) → fast (same MIR as keywords, after proof)  
> **north_star_fit:** Scientific computing / HPC · **PH-7d** · **G-dec** (primary), **G-par** (cross-link)

**Learned from:**

1. [provability-gaps.md](../../verification/provability-gaps.md) — **G-dec** row: parse + policy + `MirFn.decorators`; **no MIR lowering yet**
2. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) § 7d — sub-phase table + exit gate L72–L76
3. [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md) — compile-time elaboration to `ParallelFor` / SIMD / placement tags
4. `li-tests/decorator_exploits/` + `li-tests/decorators/` — policy vs positive elaboration delta
5. `scripts/check-mir-parallel-decorator.sh`, `check-mir-vectorized-decorator.sh` — MIR telemetry smokes today

> **Complements (not duplicates):** [#387](https://github.com/li-langverse/lic/issues/387) — **G-par** Lean discharge + proc-tag parity ([PR #1011](https://github.com/li-langverse/lic/pull/1011)); [#429](https://github.com/li-langverse/lic/issues/429) — tier-2 MD `@` on `def` workload ([PR #1003](https://github.com/li-langverse/lic/pull/1003)). **#22** owns **G-dec** elaboration exit gates **7d-b–e** and Doc-c cross-links; implementation may land in paired PRs with **#387**.

## Goal

Close the master-plan **Phase 7d / G-dec** gap: decorators move from **parse + policy + telemetry** to **full MIR elaboration** — the same proved cores as keyword `parallel for`, scoped `@vectorized for`, and host/device placement.

Deliverables:

1. **Named exit gates** for **7d-b–e** (elaboration + `decorator_exploits` CI) in phase-07 and this plan.
2. **Cross-link** **G-dec** and **G-par** wherever disjointness still uses string heuristics in `policy_module.cpp`.
3. **`provability-gaps.md`** updated in the **same PR as behavior changes** (doc-only cross-link in this plan PR).

## Non-goals

- Full **G-par** Lean iteration-independence proofs — **#387** sub-phase C (`proof_gap_researcher`).
- Tier-2 MD benchmark decorator showcase — **#429** (no `threshold_ratio_cpp` weakening).
- `@gpu` LKIR / address-space proofs — **G-gpu** (Wave 13 telemetry only today).
- `@async` structured concurrency — **G-async**.
- `trusted.lean` edits without maintainer-approved issue.
- Weakening `decorator_exploits` to advisory.

## Current state (2026-06-07)

| Sub | Asset | Status |
|-----|-------|--------|
| **7d-a** | Parse `@` on `def`/`for`/`while` | **Done** — `li-tests/decorators/*_parse_ok.li` |
| **7d-e (partial)** | Policy: reserved names, typosquat, `parallel_requires_disjoint` | **Done** — `decorator_exploits/` 4× `compile_fail` in CI |
| **7d-b (partial)** | `@cpu` on `def`; `@vectorized(lanes=4)` on `def`; `@no_vectorize` | `cpu_only_ok.li` → `mir_cpu_def=1` (`check-mir-cpu-decorator.sh`); `vectorized_dot_proc_ok.li` → `mir_vectorized_proc=1`; **no** body `ArraySimdScope` from proc tag (PR #1490) |
| **7d-c (partial)** | `@vectorized` on `for` → `ArraySimdScope` | `vectorized_for_scope_ok.li` — **done** (#150) |
| **7d-c (open)** | `@parallel(disjoint=)` on `def` → nested `parallel for` MIR | `parallel_def_disjoint_inherit.li` — `compile_ok`; **no** `mir_parallel_disjoint` on proc |
| **7d-d (partial)** | `std/execution/decorators.li` + `docs/language/decorators.md` | Handbook stub; gallery pending |
| **7d-e (open)** | `decorator def` strict naming + expansion whitelist | Exploit corpus partial; macro expansion not wired |
| **G-dec register** | Summary table L24 | MIR proc tags (`mir_cpu_def`, `mir_gpu_def`, `mir_parallel_disjoint`, `mir_vectorized_proc`); full elaboration open |
| **G-par register** | Overlap | `check_module_policies` string heuristics for race exploits — see **#387** |

**Gap (this issue):** `@cpu` / `@parallel` / `@vectorized` on `def` must **elaborate** to the same MIR lowering path as keywords — not only populate `MirFn.decorators` for telemetry.

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-7d-a/e** | Parse + policy shipped |
| **PH-7b** | `Stmt::ParallelFor` + OpenMP runtime |
| **PH-7a** | SIMD MIR + `ArraySimdScope` |
| **#387** | G-par Lean + proc-tag parity — paired implementation |
| **#429** | Production tier-2 path after B/C pass here |
| **Doc-c (#31, #29)** | Phase 02/03/07 **G-*** exit gate linking — this plan closes 7d slice |

## Plan home

- **This file** — G-dec elaboration + 7d-b–e exit gates
- **[2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md)** — 7d sub-table + Doc-c anchors (updated in plan PR)
- **Master plan** L457 — Phase **7d** checkbox cross-link

## Sub-phases and exit gates (7d-b–e)

| Sub | Deliverable | Exit gate | G-* |
|-----|-------------|-----------|-----|
| **7d-b — Elaboration core** | `@cpu` / `@parallel` / `@vectorized` on `def` lower to host placement + `ParallelFor` / proc SIMD flags in MIR | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1`; `vectorized_def_scope_ok.li` (new) → proc drives body `ArraySimdScope` | **G-dec** |
| **7d-c — Structured disjoint + scoped vectorize** | Proc `@parallel(disjoint=…)` inherits to nested loops without duplicate loop decorators; `@vectorized` on `for` remains scoped | `./li-tests/run_all.sh race_shared_memory decorators` green; `check-mir-parallel-decorator.sh` extended for inherit | **G-dec**, **G-par** (policy witnesses only until **#387** Lean) |
| **7d-d — Stdlib + handbook** | `std/execution/decorators.li` reserved-name doc + `docs/language/decorators.md` gallery (keyword ≡ decorator examples) | Handbook build / `check-doc-provability-claims.sh` pass; no false "elaborated" claims | **G-dec** (doc honesty) |
| **7d-e — Macro surface + exploits** | `decorator def` package-prefix + typosquat ban + expansion whitelist; full `decorator_exploits/` on every PR | All exploit fixtures `compile_fail` with stable codes; `./li-tests/run_all.sh decorator_exploits` in `scripts/ci.sh` | **G-dec** |

### Elaboration parity sketch (7d-b)

Keyword reference vs decorator `def` must produce equivalent MIR:

```li
# Keyword path (reference)
def step_kw(...) -> unit =
  parallel for i in 0..<N
    requires disjoint_row(i, grid)
  = ...

# Decorator path (target)
@cpu
@parallel(disjoint=disjoint_row)
@vectorized(lanes=4)
def step(...) -> unit =
  parallel for i in 0..<N
  = ...
```

Exit: `lic verify` telemetry + MIR diff (or documented delta test) shows proc-tag path ≡ keyword path for disjoint + vectorized scopes.

### G-par cross-link (7d-c)

Where elaboration still relies on `parallel_for_disjoint_witness(stmt, proc_decorators)` string/heuristic checks in `policy_module.cpp`, document as **G-par Partial** and link **#387** — do **not** mark **G-par Done** when only **G-dec** elaboration lands.

## PH / REQ / G-* mapping

| ID | Movement |
|----|----------|
| **PH-7d** | Partial → **Done** when 7d-b–e exit gates pass (master plan L457) |
| **REQ-7d-elaborate** | Decorators elaborate to MIR, not parse-only |
| **REQ-7d-exploits-ci** | `decorator_exploits` fail-closed on every PR |
| **REQ-7d-doc-c** | Phase-07 exit gates cite **G-dec** / **G-par** row IDs |
| **G-dec** | Partial → **Done** slice (elaboration + exploits CI) |
| **G-par** | Partial unchanged until **#387** Lean discharge |
| **P-dec** | Partial → closed slice when elaboration proofs land |

**Honest limit:** Closing **#22** does not alone close phase-07 L75 (tier-2 MD — **#429**) or **G-par Done** (**#387**).

## Tests / benches

| Gate | Command / artifact |
|------|-------------------|
| Exploit corpus | `./li-tests/run_all.sh decorator_exploits` |
| Positive decorators | `./li-tests/run_all.sh decorators` |
| Disjoint policy | `./li-tests/run_all.sh race_shared_memory` |
| MIR smokes | `scripts/check-mir-parallel-decorator.sh`, `check-mir-vectorized-decorator.sh` |
| Proc inherit (new) | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1` |
| Vectorized def (new) | `vectorized_def_scope_ok.li` |
| Doc gate | `scripts/check-doc-provability-claims.sh` |
| Tier-2 advisory | **#429** after B/C — no threshold weakening |

## Vision checks

| Check | Result |
|-------|--------|
| Proof-before-perf | Yes — MIR elaboration before tier-2 perf claims |
| Strict-by-default | Yes — exploits remain compile errors |
| Benchmark threshold gaming | **Rejected** |
| New org repo | Not needed |
| `trusted.lean` | Out of scope (**#387** sub-phase C, human-only) |

## Rollout (implementation PRs, post-`plan-approved`)

1. **lic PR 1 (elaboration):** 7d-b + 7d-c — `lower.cpp`, `mir.hpp`, `policy_module.cpp` inherit path; new decorator tests; MIR scripts.
2. **lic PR 2 (surface):** 7d-e — `decorator def` expansion whitelist + extended `decorator_exploits/`.
3. **lic PR 3 (docs):** 7d-d + **G-dec** row in `provability-gaps.md` + phase-07 Doc-c anchors; master plan L457 checkbox when gates pass.
4. Pair with **#387** Lean PR when proc-tag parity tests from that plan are ready.
5. Unblock **#429** implementer after 7d-b exit gate.
6. Close **#22** when acceptance boxes checked.

## Human-only

- [ ] Review and merge this plan PR
- [ ] Add label **`plan-approved`** on [#22](https://github.com/li-langverse/lic/issues/22)
- [ ] Remove **`plan-needed`** if present after ack
- [ ] Route elaboration PRs to **code_implementer**; Lean **G-par** to **proof_gap_researcher** via **#387**

