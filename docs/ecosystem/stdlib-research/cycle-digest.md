# Stdlib research cycle digest

**Agent:** `stdlib_researcher`  
**Goal:** `stdlib_ecosystem` (config/research-goals.yaml)  
**north_star_fit:** Deep std + li-std-* audit; packages to build vs improve — domains: ecosystem, scientific_computing, hpc  
**Org vision:** [vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — proof → easy → fast  
**Cycle:** 1 (in progress)  
**Last step:** 2026-05-19 — `inventory_std_tree` (`lic/std/**`)

---

## Executive summary

- On-disk `lic/std/**` ships **two modules** only: `std.bytes.bytes` (22 lines) and `std.execution.decorators` (16 lines); no `std/io`, `std/csv`, `std/summary`, or `std/plot` trees exist.
- Benchmarks ingest/dashboard scripts **already import** the four missing modules (`benchmarks/scripts/ingest/*.li`); they cannot compile against current lic std surface.
- `li-std-core` is a **version stub** (8 lines, `li_std_core_version` only); `li-std-math` / `li-std-numerics` carry real APIs (226 / 195 lines in `src/lib.li`).
- Eleven `li-std-physics-*` packages exist in the monorepo workspace (`packages/li.toml` L3–L17) with tiered domain types; **no org mirrors** yet (explorer briefing, issue #50).
- `std/bytes` documents httpd P0 wire types with `extern` stubs; implementation deferred to a future `li-bytes` package (`std/bytes/bytes.li` L1, L7–10).
- `std/execution/decorators` is **documentation-only** (`__execution_decorators_doc`); reserved decorator names listed L6–8; lowering tracked under PH-7e / lic#15, #34.
- Std seal / coverage policy requires 100% line coverage and `gen-stdlib-manifest.sh` sync when exports grow (`.cursor/rules/li-stdlib.mdc` L9–17).
- **Next focus step:** `audit_package` → `li-std-core` (sample), then `gap_vs_sota` linear algebra.

---

## Deliverable / findings

### Step 1 — `inventory_std_tree` (`lic/std/**`)

| Module path | Lines | Public surface (evidence) | Status |
|-------------|-------|---------------------------|--------|
| `std/bytes/bytes.li` | 22 | Types `Bytes`, `StringView`, `Reader`, `Writer`; `extern proc bytes_len`, `bytes_slice` with contracts L12–22 | Stub — defers impl to future package L7–10 |
| `std/execution/decorators.li` | 16 | `def __execution_decorators_doc() -> int` L11–16; reserved names doc L6–8 | Doc-only; compiler elaborates decorators at compile time L3–5 |
| `std/io`, `std/csv`, `std/summary`, `std/plot` | — | — | **Absent** on disk |

**Importer pressure (benchmarks repo, file:line):**

| Expected module | Import site | PH |
|-----------------|-------------|-----|
| `std.io`, `std.csv` | `benchmarks/scripts/ingest/csv_ingest_smoke.li` L2–3 | PH-IO-4 |
| `std.summary` | `benchmarks/scripts/ingest/build_summary.li` L2; `build_summary_fixture.li` | PH-IO-7 |
| `std.plot` | `benchmarks/scripts/dashboard/render_dashboard.li` (explorer refs) | PH-IO-5 |

**Compiler / test wiring (lic):**

- `li-tests/stdlib_coverage/build_std_decorators.li` L1: `import std.execution.decorators`
- `li-tests/modules/import_std_decorators.li` L1: same
- `scripts/gen-stdlib-manifest.sh` L2–10: scans `std/**/*.li` for seal manifest
- `docs/language/stdlib.md` L11–13: documents minimal shipped std; Phase 8a for full imports

**Hypothesis (step 1):** The std **tree inventory is the bottleneck** for PH-IO ingest and for decorator lowering proof — not package count.  
**Verdict:** **verified** — only 2 of 6 benchmark-referenced std modules exist; packages are ahead of `std/`.

### `li-std-*` monorepo inventory (context for later steps)

| Package | `src/lib.li` lines | Notes |
|---------|-------------------|--------|
| `li-std-core` | 8 | Stub only (`packages/li-std-core/src/lib.li` L3–8) |
| `li-std-math` | 226 | Vec/Quat/Mat4 + runtime math (`extern` L3–6) |
| `li-std-numerics` | 195 | Integrators e.g. `euler_step_vec2` L14+ |
| `li-std-physics-core` | 124 | Profiles, units, stepping types L3–29+ |
| `li-std-physics-*` (11 domain) | 29–86 each | Scaffold domain APIs; workspace member list `packages/li.toml` L3–17 |

Org mirrors today: `li-std-core`, `li-std-math`, `li-demo`, `li-net`, `li-httpd` (briefing `org_mirror_repos`); physics packages path-only in monorepo.

---

## Recommended issues/PRs

| Title | Repo | Labels (suggested) |
|-------|------|-------------------|
| [Ecosystem gap] PH-IO-4/5/7: ship std.io, std.csv, std.summary, std.plot | `li-langverse/lic` #13 | `ecosystem`, `PH-IO`, `stdlib` |
| [Ecosystem gap] PH-7e/G-par: decorators → portable parallel lowering | `li-langverse/lic` #15 | `ecosystem`, `PH-7e`, `stdlib` |
| Map std/execution decorators to LLVM OpenMP IR / MLIR omp | `li-langverse/lic` #34 | `explorer-finding`, `G-par` |
| [Ecosystem gap] Physics packages: scaffold lib.li → domain APIs | `li-langverse/lic` #14 | `ecosystem`, `physics` |
| Publish li-std-physics-* org mirrors (12 packages) | `li-langverse/lic` #50 | `ecosystem`, `packaging` |

**Handoff (next agents):** `package_architect` — PH-IO std module layout + seal manifest plan; `code_implementer` — do not implement in this research pass.

---

## Deferred

- **Step 2:** `audit_package` → `li-std-core` (coverage, composable API vs stub)
- **Step 3:** `gap_vs_sota` — Eigen/Kokkos/PETSc vs `li-std-math` / `std/execution`
- **Step 4:** `synthesize_step` — cycle summary with final `packages_to_build`, `packages_to_improve`, `std_modules_to_add`, `connections`
- **Web/SOTA scrape** — briefing `web_search_queries`; not run this step
- **`trusted.lean`** — human-approved issues only (swarm mandate)

---

## Incremental cycle outputs (partial)

### `std_modules_to_add` (confirmed missing on disk)

- `std.io` — PH-IO-4
- `std.csv` — PH-IO-4
- `std.summary` — PH-IO-7
- `std.plot` — PH-IO-5
- (future) `std/signal` or vendor FFT hook — catalog gap per benchmarks #18

### `packages_to_improve` (tentative; full audit deferred)

- `li-std-core` — expand beyond version stub; align with org mirror `li-std-core`
- `li-std-math`, `li-std-numerics` — pure-Li / SIMD path vs Eigen (lic #27, #33)
- `li-std-physics-*` — domain API depth vs shared_c_kernel benches (lic #14)

### `packages_to_build` (tentative)

- `li-bytes` (or equivalent) — implement `Reader`/`Writer` promised in `std/bytes/bytes.li` L7–10
- Org mirrors for 12 physics packages (lic #50)

### `connections`

- `std.io`/`std.csv` → `benchmarks` ingest (`csv_ingest_smoke.li`) → `data/latest/summary.json` via `std.summary`
- `std.execution.decorators` → compiler lowering → OpenMP/Kokkos-class policies (lic #15, #34)
- `std.bytes` → `li-httpd` P0 prerequisites (`docs/ecosystem/httpd-prerequisites.md`)
