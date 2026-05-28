# Stdlib ecosystem digest — session `cee09172-b61f-4f7b-84de-aae2d0e5972f` (cycle 1)

**Agent:** `stdlib_researcher` · **Goal:** `stdlib_ecosystem` · **north_star_fit:** ecosystem, scientific_computing, hpc  
**Completed steps:** `inventory_std_tree-1`, `gap_vs_sota-linalg-1`  
**Repo:** `lic` · **Cycle digests:** `docs/ecosystem/stdlib-research/`  
**Whitepaper:** `research-findings/whitepapers/2026-05/stdlib_ecosystem/std-r0-cycle1-linalg-gap/`

---

## Executive summary

- Inventoried **25** `lic/std/**/*.li` modules; `std/math` is tag-only — **dense LA is prelude/compiler**, not std tree.
- **2i/7e partial:** `dot`, `sum`, `norm`, `axpy`, 1d/2d `@` with **26** `math_linalg` tests; **no** `packages/linalg`, `std.tensor`, or LAPACK-class APIs.
- **SOTA gaps:** full broadcast, sparse, decompositions/solvers; **`simd_dot` bench** still uses extern C kernel (7e-a doc drift).
- **Perf:** `matmul_naive` advisory OK; **`matmul_blocked` / `horner_pure_li`** fail strict ≤1.2× (G-math Partial).
- **`li-std-math`** mirrors `li-math` structs; **`li-std-core`** is a version stub.
- Hand off **AL-10** / pure-Li tier-1 to `package_architect` → `code_implementer`; **synthesize_step** next.

---

## Step artifacts

| Step | Artifact |
|------|----------|
| `inventory_std_tree-1` | [cycle-1-inventory-std-tree.md](../stdlib-research/cycle-1-inventory-std-tree.md) |
| `gap_vs_sota-linalg-1` | [cycle-1-gap-vs-sota-linalg.md](../stdlib-research/cycle-1-gap-vs-sota-linalg.md) |

---

## Incremental YAML (updated each step)

```yaml
packages_to_build:
  - packages/linalg
  - std.tensor
  - std.sparse
packages_to_improve:
  - li-std-math
  - packages/li-math
  - packages/li-math-numerics
  - benchmarks/tier1_micro/simd_dot/li
std_modules_to_add:
  - std.summary
  - std.plot
  - std.http.*
  - std.tensor
  - std.sparse
  - std.linalg
connections:
  - prelude @ / dot → compiler MIR → codegen
  - packages/li-math → prelude @
  - li-std-math → mirror of li-math
  - li-tests/math_linalg → compiler gates
  - packages/lig → FFI matmul (parallel track)
  - WP0-B stubs → prelude (blocked: WP-WA)
```

---

## Queue (remaining)

1. `synthesize_step` — cycle summary
