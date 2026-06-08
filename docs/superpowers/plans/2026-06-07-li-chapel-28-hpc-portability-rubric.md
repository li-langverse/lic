# Chapel 2.8 HPC portability rubric → Li `std/execution` + tier-2 physics (G-par, G-ai)

> **Issue:** [#113](https://github.com/li-langverse/lic/issues/113) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first (disjoint + execution-space proofs), **Easy** syntax (decorator-native surface), **Fast** only after proof (portable backends)  
> **north_star_fit:** HPC / scientific computing portability · **PH-7d**, **PH-7e**, **PH-5b** · **G-par**, **G-gpu**, **G-ai**  
> **Learned from:** [Chapel 2.8 release](https://chapel-lang.org/blog/posts/announcing-chapel-2.8/), [HPSF Chapel 2.8 summary](https://hpsf.io/blog/2026/chapel-2-8-released/), [execution surface spec](../specs/2026-05-25-li-execution-surface.md), [parallel design spec](../specs/2026-06-06-li-parallel-design.md), [Kokkos memory spaces plan sibling lic#110](https://github.com/li-langverse/lic/issues/110)

## Goal

Close the explorer **partial** rubric for **Chapel 2.8 HPC portability** by producing a **normative checklist** that:

1. Extracts Chapel 2.8 portability signals (RISC-V/qthreads, ROCm 6.3/7, LLVM 21, Slurm launcher flags, CLS/Mason tooling) into Li-facing **acceptance rows** for `std/execution` and tier-2 physics — **without adopting Chapel runtime or PGAS locale model**.
2. **Extends** [lic#54](https://github.com/li-langverse/lic/issues/54) (Chapel 2.3+ Python/NumPy interop reference) with a **companion HPC portability slice** — distinct scope, shared competitive-intel process.
3. Aligns decorator / execution-space semantics with sibling rubrics [lic#109](https://github.com/li-langverse/lic/issues/109) (RAJA policies) and [lic#110](https://github.com/li-langverse/lic/issues/110) (Kokkos Views + memory spaces).

**No product codegen** in this slice — documentation, normative rubric, gap-registry updates only.

## Non-goals

- Implementing Chapel runtime, qthreads, or Chapel multi-locale PGAS in **lic**.
- Adding a Chapel driver column to `bench_tier2` or weakening `threshold_ratio_cpp`.
- Duplicating [lic#54](https://github.com/li-langverse/lic/issues/54) Python/NumPy interop policy — cross-link only.
- Replacing [lic#109](https://github.com/li-langverse/lic/issues/109) RAJA policy matrix or [lic#110](https://github.com/li-langverse/lic/issues/110) Kokkos View ABI rubric.
- Editing `trusted.lean` (human-approved issues only).
- Adding GitHub Actions `schedule:` cron.

## Distinction from sibling explorer issues

| Issue | Abstraction | This plan (#113) |
|-------|-------------|------------------|
| **lic#54** Chapel 2.3+ | Python/NumPy **foreign bindings** reference (G-ai) | **HPC portability checklist** for execution backends + launchers |
| **lic#109** RAJA | Static **execution policies** on loop bodies | **Platform/back-end portability axes** (arch, GPU stack, launcher) |
| **lic#110** Kokkos | **Views + memory spaces** ABI | Cross-link decorator → memory-space mapping; checklist row ownership stays #110 |
| **lic#125** std::execution | Sender/receiver **async overlap** | Bulk `parallel for` + backend portability only |
| **benchmarks#27** | Release cadence tracker | Evidence pin for Chapel 2.8.0; no catalog threshold change |

## Chapel 2.8 → Li portability checklist (summary)

Full normative detail: [Chapel 2.8 portability checklist spec](../specs/2026-06-07-li-chapel-28-portability-checklist.md).

| Chapel 2.8 signal | Li checklist row | Proof / PH axis | Owner issue |
|-------------------|------------------|-----------------|-------------|
| RISC-V + Qthreads 1.23 lightweight tasking | Host task pool + `@parallel` on non-PGAS single-node tier-2 | **G-par** · PH-7b/7d | #113 |
| ROCm 6.3/7 AMD GPU | Decorator `@gpu` → ROCm/HIP execution space (future) | **G-gpu** · PH-7e | **lic#110** (memory spaces) |
| LLVM 21 compiler backend | Loop-invariant vectorization **metadata goals** for `@vectorized` | **G-par** · PH-7e | #113 → PH-7e |
| `--system-launcher-flags` (Slurm) | `lipar run` / launcher passthrough checklist (no Chapel launcher) | **G-par-dist** · PH-7 | #113 |
| CLS + `chplcheck` + Mason | Vision-LLM / `lic diagnose` ergonomics reference | **G-ai** (doc) | **lic#54** companion |
| EX troubleshooting docs | Competitive landscape quarterly review row | Doc-only | benchmarks#27 |

**Rule:** Li proves **disjoint iteration** and **structured execution** first; backend portability rows are **honest Partial** until PH-7e lowering + G-par Lean proofs land. Chapel productivity wins inform **checklist rows**, not runtime adoption.

## Tier-2 physics portability matrix

Evidence: tier-2 harness rows ([WP-T2 release notes](../../release-notes/2026-05-25-tier2-physics-li-builds-wp-t2.md)), `packages/li-sim-scientific` oracle dispatch.

| Kernel / family | Portability axes (v1 checklist) | Chapel analogue (reference only) | Li v1 surface | Proof axis |
|-----------------|--------------------------------|----------------------------------|---------------|------------|
| `md_lennard_jones` / `three_body` | Host OpenMP, `--cores` | `forall` over locales (we: single-node) | `@parallel(disjoint=)` | **G-par** |
| `heat_equation_2d` / stencils | SIMD + OpenMP tile | loop-invariant vectorization (LLVM 21) | `@vectorized` + `@parallel` | **G-par** · PH-7e |
| `rigid_body_stack` / `cloth_swing` | Host parallel + future async overlap | multi-locale tasking (watch) | `@parallel` today; lic#125 async later | **G-par** |
| GPU offload candidates (watch) | ROCm/HIP memory space | Chapel GPU on AMD ROCm 6.3/7 | `@gpu` stub + lic#110 Views | **G-gpu** |
| Slurm batch jobs | Launcher flag passthrough | `--system-launcher-flags` | `lipar run -- …` checklist | **G-par-dist** |

## Dependencies

| Track | Issue / doc | Role |
|-------|-------------|------|
| Decorator AST | PH-7d, `std/execution/decorators.li` | Baseline reserved names |
| Parallel proofs | PH-7b, **G-par** | `disjoint=` for bulk loops |
| Memory spaces | PH-7e, **lic#110** | Kokkos-class View ABI |
| Policy matrix | **lic#109** | RAJA policy ↔ decorator mapping |
| Foreign bindings reference | **lic#54** | G-ai tooling ergonomics companion |
| Release tracker | **benchmarks#27** | Chapel 2.8.0 pin |
| Tier-2 harness | PH-5b, WP-T2 | Bench honesty rows |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | Normative checklist spec: Chapel 2.8 signal → Li row table | Merged spec doc; `check-doc-provability-claims.sh` |
| **B** | `std/execution` decorator ↔ backend axis matrix (cross lic#109, #110) | Linked from issue #113 + `competitive-landscape.md` |
| **C** | Tier-2 physics portability matrix (this plan § table) | Five WP-T2 kernel ids cited |
| **D** | PH-7e LLVM loop-invariant vectorization metadata goals (doc) | Master plan §7e cross-link; no codegen |
| **E** | Agent tooling row: CLS/Mason → `lic diagnose` (extends lic#54) | One-page cross-link; no FFI implementation |
| **F** | Swarm gap `gap-hpc-chapel-28-portability-rubric` + registry bump | Registry YAML + competitive `registry.toml` `last_reviewed` |

## Tests / benches

| Gate | Command / artifact | When |
|------|-------------------|------|
| Doc honesty | `./scripts/check-doc-provability-claims.sh` | Every PR |
| HPC competitive | `./scripts/check-hpc-competitive.sh` | After `registry.toml` bump |
| Tier-2 smoke (unchanged) | `python3 benchmarks/harness/bench.py --tier 2 --only md_lennard_jones,heat_equation_2d` | After implementation slices |
| Race rejects | `li-tests/race_shared_memory/` | Before any new parallel codegen |

**REQ mapping:**

| REQ | Acceptance |
|-----|------------|
| REQ-chapel-28-checklist | Spec table covers all six Chapel 2.8 signals from issue #113 |
| REQ-tier2-portability-doc | Matrix matches five WP-T2 kernel ids |
| REQ-7e-lic-metadata | PH-7e subsection cites loop-invariant vectorization without claiming shipped codegen |

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-par** | Partial → Partial (honest) | Checklist documents backend axes; proofs unchanged |
| **G-gpu** | Partial → Partial (honest) | ROCm rows defer to lic#110 memory-space ABI |
| **G-ai** | Stub → Stub (doc cross-link) | CLS/Mason ergonomics reference only; full row in lic#54 plan |
| **G-par-dist** | Partial (doc) | Slurm passthrough checklist; `lipar run` spec cross-link |

## Rollout

1. [x] Merge **this plan PR** — normative checklist + tier-2 matrix shipped ([PR #1038](https://github.com/li-langverse/lic/pull/1038)).
2. [x] **`plan-approved`** on #113 — rubric v1 complete; no product codegen in this slice.
3. **lic#110** / **lic#109** implementers consume rows B–C; no duplicate matrices.
4. **lic#54** planner adds G-ai tooling subsection referencing sub-phase E.
5. Backend codegen handoff only after PH-7e tracks explicitly scoped (ROCm, vectorization metadata).

## Human-only

- [x] Label **`plan-approved`** on #113 before backend codegen agents run.
- [ ] Decide whether Chapel stays **`watch`** or gains **`bench_tier2`** reference driver (recommend: stay watch until G-par proofs advance).
- [ ] Approve Slurm passthrough syntax for `lipar run` vs env-only flags.
