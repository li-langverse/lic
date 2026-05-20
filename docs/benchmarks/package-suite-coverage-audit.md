# Package ↔ benchmark suite coverage audit

**Purpose:** Map **science / maths / physics / engineering / gaming** surfaces in `packages/*` to **measurement** (`benchmarks/tier*`, `li-tests/composable`) under [**strict by default**](../ecosystem/strict-by-default.md) (`lic build` = certificate path; contracts on `proc` / `extern proc`).

**Org dashboard:** [benchmarks `catalog.toml`](https://github.com/li-langverse/benchmarks/blob/main/catalog.toml) (ingest from `lic/benchmarks/results/latest.csv`).

---

## Pillar → packages → harness / gates

| Pillar | Representative packages | Tier-1 / micro (maths) | Tier-2 physics / PDE | Composable / integration | Known gaps |
|--------|---------------------------|-------------------------|----------------------|---------------------------|------------|
| **Maths & numerics** | `li-math`, `li-math-numerics` | `matmul_*`, `horner_pure_li`, `reduce_sum`, `simd_dot` | — | Import smokes if exposed as libs | **No** dedicated `li-math` kernel bench rows yet — extend `tier1_micro` or `bench_ecosystem` |
| **Physics (core + domains)** | `li-physics-core`, `li-physics-*` (fluids, rigid, …) | — | `md_lennard_jones`, `nbody_gravity`, `wave_*`, `heat_*`, `euler_fluid_2d`, `sph_*`, `rigid_body_stack`, … | `import_sim_*`, world/physics stacks | Some tier-2 Li entrypoints still fragile — fix under **strict** before timing |
| **Engineering simulations** | `li-sim`, `li-sim-scientific`, `li-sim-robotics`, `li-sim-automotive`, `li-sim-drug-design`, `li-sim-additive` | — | Overlap with tier-2 where kernels shared | **Composables** (`import_sim_scientific`, spin-ups, quick stacks) | **Perf:** composables = compile/import gates, not GFLOPS — add harness rows when kernels stabilize |
| **Science / chem / bio** | `li-chem`, `li-bioeng`, `li-sim-drug-design` | — | `combustion_passive`, tier-2 stubs | `import_scientific_drug_chem`, bioeng bridges | Align with **li-std-physics-*** org mirrors when present |
| **Gaming / world / studio** | `li-world`, `li-studio`, `li-scene`, `li-render`, `li-player` | — | `cloth_swing`, custom physics path | World Studio composables, **165+** gates on branch | **sim_step_physics** still blocked per status docs — proof/typing |

---

## Strict compilation (new / enforced modes)

Per **strict-by-default** policy and `li-strict-by-default.mdc`:

- **`lic build`** on benchmark Li shims must succeed with **`--release`** (and Lean verify when enabled for that path).
- Every **`extern proc`** in bench `main.li` must declare **`requires` / `ensures`**; **`main`** that calls extern must declare **`raises IO`** when the compiler requires it (tier-2 pattern).
- Do not land bench shims that only pass `lic check` — **`lic build` is the certificate path**.

When strictness tightens (e.g. new contract defaults), **fix bench Li first**, then refresh timings — never silence with `sorry` / bare cast.

---

## Enforcement checklist (agents)

1. **Changed a `packages/*` numerical or physics kernel?** → Add or extend **`benchmarks/tier*`** row **or** file a tracked gap in this doc + `provability-gaps.md` / issue.
2. **New public sim API (`sim.*`)?** → Add **`li-tests/composable`** + manifest row; for perf claims add **catalog** row in **benchmarks** repo.
3. **Before merge:** `./scripts/ci-bench.sh` (tier-1) on PR branch; tier-2 when touching physics harness.
4. **Cross-repo:** update **benchmarks** `catalog.toml` paths only when **`lic`** directories exist (see benchmarks plan-completion-audit).

---

## Revision log

| Date | Note |
|------|------|
| 2026-05-20 | Initial audit: pillars, packages, strict build alignment, gap column |
