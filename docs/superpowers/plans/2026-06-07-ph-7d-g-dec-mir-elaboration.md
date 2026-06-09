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

- Full **G-par** Lean iteration-independence proofs — **#387**
- Tier-2 MD benchmark decorator showcase — **#429**
- `@gpu` LKIR / address-space proofs — **G-gpu**
- `@async` structured concurrency — **G-async**
- `trusted.lean` edits without maintainer-approved issue
- Weakening `decorator_exploits` to advisory

## Sub-phases and exit gates (7d-b–e)

| Sub | Deliverable | Exit gate | G-* |
|-----|-------------|-----------|-----|
| **7d-b — Elaboration core** | `@cpu` / `@parallel` / `@vectorized` on `def` lower to host placement + `ParallelFor` / proc SIMD flags in MIR | `cpu_only_ok.li` → `mir_cpu_def=1`; `vectorized_def_scope_ok.li` → `mir_vectorized_def_scope=1` | **G-dec** |
| **7d-c — Structured disjoint + scoped vectorize** | Proc `@parallel(disjoint=…)` inherits to nested loops; `@vectorized` on `for` remains scoped | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1`; `check-mir-parallel-decorator.sh` | **G-dec**, **G-par** (policy witnesses until **#387** Lean) |
| **7d-d — Stdlib + handbook** | `std/execution/decorators.li` + `docs/language/decorators.md` gallery | Handbook build / `check-doc-provability-claims.sh` pass | **G-dec** (doc honesty) |
| **7d-e — Macro surface + exploits** | `decorator def` package-prefix + typosquat ban + expansion whitelist | All exploit fixtures `compile_fail`; `./li-tests/run_all.sh decorator_exploits` in `scripts/ci.sh` | **G-dec** |

### G-par cross-link (7d-c)

Where elaboration still relies on `parallel_for_disjoint_witness(stmt, proc_decorators)` string/heuristic checks in `policy_module.cpp`, document as **G-par Partial** and link **#387** — do **not** mark **G-par Done** when only **G-dec** elaboration lands.

## PH / REQ / G-* mapping

| ID | Movement |
|----|----------|
| **PH-7d** | Partial → **Done** when 7d-b–e exit gates pass (master plan L457) |
| **G-dec** | Partial → closed slice (elaboration + exploits CI) |
| **G-par** | Partial unchanged until **#387** Lean discharge |
| **P-dec** | Partial → closed slice when elaboration proofs land |

**Honest limit:** Closing **#22** does not alone close phase-07 L75 (tier-2 MD — **#429**) or **G-par Done** (**#387**).

## Tests / benches

| Gate | Command / artifact |
|------|-------------------|
| Exploit corpus | `./li-tests/run_all.sh decorator_exploits` |
| Positive decorators | `./li-tests/run_all.sh decorators` |
| Disjoint policy | `./li-tests/run_all.sh race_shared_memory` |
| MIR smokes | `scripts/check-mir-cpu-decorator.sh`, `check-mir-parallel-decorator.sh`, `check-mir-vectorized-decorator.sh` |
| Doc gate | `scripts/check-doc-provability-claims.sh` |
