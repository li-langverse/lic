# Stdlib ecosystem — cycle 1 · `synthesize_step` (cycle summary)

**Session:** `cee09172-b61f-4f7b-84de-aae2d0e5972f` · **Goal:** `stdlib_ecosystem` · **Step:** `synthesize_step`  
**Agent:** `stdlib_researcher` · **north_star_fit:** ecosystem, scientific_computing, hpc · **PH:** 2i, 7e, IO-4/5/7, AL-10, AL-11  
**Cycle status:** complete · **Repo:** `lic` (workflow) · **Publish:** `research-findings/whitepapers/2026-05/stdlib_ecosystem/std-r0-cycle1-ecosystem-summary/`

---

## Executive summary

- **25** `lic/std/**/*.li` modules inventoried; only **`std.bytes`** (117 LOC) and **`std.runtime.seam`** (655 LOC) carry real runtime surface; **WP0-B** stubs ship for `collections` / `heap` / `algorithms` (compile-only, WP-WA blocked).
- **Dense linear algebra is not in `std/math`** — prelude/compiler owns `dot`, `sum`, `norm`, `axpy`, 1d/2d `@`; `std/math` is tag-only (`math.li:1-6`).
- **SOTA functional gap:** no `packages/linalg`, `std.tensor`, sparse, full broadcast, or LAPACK-class APIs — **AL-10** / Phase 3 track.
- **SOTA perf gap (7e):** `matmul_naive` advisory OK; **`matmul_blocked`** and **`horner_pure_li`** fail strict ≤1.2×; briefing reds include `horner_pure_li`, `reduce_sum`.
- **`simd_dot` tier-1 Li driver** still calls `extern proc li_simd_dot_kernel()` — not the documented pure-Li math path.
- **`li-std-math`** mirrors `packages/li-math` with weaker `vec3_dot` contracts; **`li-std-core`** is a version stub only.
- **Docs/ingest drift:** `stdlib.md` and `ecosystem-explorer.json` omit WP0-B modules; **`std.summary`** / **`std.plot`** still missing (PH-IO-7 / PH-IO-5).
- **Handoff:** prioritized build/improve queue below → **`package_architect`** (placement) → **`code_implementer`** (AL-10, 7e-a bench, WP0-B runtime after Wave A).

---

## Deliverable / findings

### Step rollup

| Step | Digest | Primary outcome |
|------|--------|-----------------|
| `inventory_std_tree-1` | [cycle-1-inventory-std-tree.md](./cycle-1-inventory-std-tree.md) | Maturity map, CI harness links, planned-not-on-disk modules |
| `gap_vs_sota-linalg-1` | [cycle-1-gap-vs-sota-linalg.md](./cycle-1-gap-vs-sota-linalg.md) | Prelude vs BLAS/LAPACK/NumPy matrix; perf + proof gaps |
| `synthesize_step` | this file | Consolidated YAML + prioritized implementer queue |

### Std tree vs packages (placement)

| Layer | Role today | Build vs improve |
|-------|------------|------------------|
| `lic/std/**` | Import facades, seam, WP0-B stubs, physics tags | **Improve** docs/CI honesty; **add** `tensor`, `sparse`, `summary`, `plot`, httpd modules per plans |
| Prelude + compiler | Primary LA + shape errors | **Improve** 7e perf, float Props (G-math) |
| `packages/li-math` | Vec3/4, Quat, Mat4, `array_dot_f64` → `@` | **Improve** AL-11 (slerp, mat4_mul) |
| `packages/linalg` | **Missing** (AL-10) | **Build** |
| `li-std-math` | Org mirror of `li-math` | **Improve** contract parity |
| `li-std-core` | Version stub | **Defer** until core types move out of monorepo |

### Proof-before-perf gates (do not skip)

- **G-math** Partial — strict tier-1 and float `@` Props open ([provability-gaps.md](../verification/provability-gaps.md)).
- **WP0-B runtime** blocked on Wave A **G-vc**, **G-lean**, **G-par**, **G-math** ([wave-a-stdlib-unblock-checklist.md](../wave-a-stdlib-unblock-checklist.md)).
- No `trusted.lean` edits from this research pass.

### Implementer priority queue

| P | Item | Owner agent | PH / AL |
|---|------|-------------|---------|
| 1 | Scaffold `packages/linalg` + composable import smoke | package_architect → code_implementer | AL-10, 2i |
| 2 | Pure-Li `simd_dot` bench (remove extern kernel) | code_implementer | 7e-a |
| 3 | Close `matmul_blocked` + `horner_pure_li` under `LI_TIER1_PERF_STRICT=1` | bench_improver / code_implementer | 7e, G-math |
| 4 | Align `li-std-math` `vec3_dot` with `packages/li-math` | code_implementer | ecosystem |
| 5 | Refresh `stdlib.md` + explorer `std_modules_on_disk` | docs_maintainer | stdlib |
| 6 | `std.summary` / `std.plot` for PH-IO ingest | package_architect → code_implementer | IO-7, IO-5 |
| 7 | WP0-B → runtime collections (post Wave A) | code_implementer | PH-2 |

---

## Cycle 1 consolidated outputs

```yaml
packages_to_build:
  - packages/linalg          # AL-10: solve, decompositions; re-export prelude GEMM
  - std.tensor               # Phase 3 / AL-17 rank-N surface (facade when types land)
  - std.sparse               # Phase 3 sparse LA
packages_to_improve:
  - li-std-math              # contract parity with packages/li-math (vec3_dot ensures)
  - packages/li-math         # AL-11: quat_dot/slerp, mat4_mul, scene wire-up
  - packages/li-math-numerics  # num_dot_axpy registry entry (today integrators only)
  - benchmarks/tier1_micro/simd_dot/li  # pure-Li dot per 7e-a exit gate
  - lic/std (docs + coverage)  # stdlib.md, check-stdlib-coverage, explorer rescan
std_modules_to_add:
  - std.summary              # PH-IO-7 (explorer missing)
  - std.plot                 # PH-IO-5
  - std.http.*               # httpd M1+ (router, config, upstream)
  - std.tensor
  - std.sparse
  - std.linalg               # optional facade over packages/linalg — architect decision
connections:
  - prelude @ / dot / sum / norm / axpy → compiler/mir/lower.cpp → codegen/emit.cpp
  - packages/li-math.array_dot_f64 → prelude @
  - li-std-math → mirror of lic/packages/li-math (org publish)
  - lic/std/runtime/seam.li → li_rt_net.c (httpd, proxy, TLS hooks)
  - lic/std/bytes → packages/li-bytes
  - li-tests/math_linalg → compiler LA gates (not std/math)
  - li-tests/stdlib_seal → WP0-B import smoke
  - packages/lig → FFI matmul_f32 (parallel track to pure-Li tier-1)
  - WP0-B stubs → prelude list/dict (blocked: Wave A G-vc, G-lean, G-par, G-math)
  - sim algo_registry num_dot_axpy → blocked on li-math-numerics
```

---

## Recommended issues/PRs

| Repo | Title | Labels |
|------|-------|--------|
| **lic** | feat(AL-10): scaffold `packages/linalg` + composable `import` smoke | `PH-2i`, `stdlib`, `ecosystem` |
| **lic** | bench(7e-a): rewrite `simd_dot` Li driver to pure `dot` / `a @ b` | `PH-7e`, `benchmarks` |
| **lic** | perf(7e): close `matmul_blocked` + `horner_pure_li` for strict tier-1 | `PH-7e`, `G-math` |
| **lic** | docs: refresh `stdlib.md` shipped tree (WP0-B modules) | `documentation`, `stdlib` |
| **benchmarks** | ecosystem-explorer: rescan `std_modules_on_disk` (collections/heap/algorithms) | `ecosystem` |
| **lic** | tracking: `std.summary` / `std.plot` for PH-IO ingest | `PH-IO-7`, `PH-IO-5` |
| **li-std-math** | chore: align `vec3_dot` contracts with `lic/packages/li-math` | `ecosystem`, `mirror` |
| **lic** | proof(2f): float `vec3_dot` / 2D `@` Lean Props (P-linalg backlog) | `PH-2f`, `provability` |
| **lic** | merge `cursor/stdlib-adt-wp0` per ph-db battle plan §6 | `stdlib`, `wave-a` |

---

## Deferred

- **Cycle 2+:** full `li-std-*` org audit beyond `li-std-core` stub + `li-std-math` mirror cross-read.
- **Product implementation** in this pass — all code changes via `package_architect` → `code_implementer`.
- **`trusted.lean` / MIR semantic proofs** — human-gated.
- **GPU GEMM / vendor BLAS bindings** — out of std scope; `packages/lig` research track only.
- **Httpd std modules** (`std/http`, `std/net`, `std/tls`) — separate httpd plan loop after M1 gates.

---

## Handoff

**north_star_fit:** ecosystem, scientific_computing, hpc · **PH-2i**, **PH-7e**, **PH-IO-5/7**, **AL-10**, **AL-11**  
**Whitepaper:** [std-r0-cycle1-ecosystem-summary](https://github.com/li-langverse/research-findings/tree/main/whitepapers/2026-05/stdlib_ecosystem/std-r0-cycle1-ecosystem-summary)  
**Session rollup:** [stdlib_ecosystem-cycle.md](../research-sessions/stdlib_ecosystem-cycle.md)
