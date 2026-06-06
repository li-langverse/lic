# Compiler audit — BUG-C gap register

**Phase:** Proof Explorer phase 9 (`proof-explorer-phase9-compiler-gaps`) · phase 10 axiom RFC [BUG-C-13](BUG-C-13-li-axiom-declarations.md)  
**Gap scripts:** `li-tests/tooling/*_gap.sh` (run via `scripts/proof-explorer-gates/wp-compiler-gap-regression.sh`)

Agents **must not** edit `compiler/` from proof-explorer goals. File or update the matching `BUG-C-*.md` and adjust catalog/docs when claims are wrong.

## Index

**Regression** (`wp-compiler-gap-regression.sh`, `lic` built): **PASS** = gap script exit 0 (documented state holds); **OPEN** = exit 1 (unexpected vs audit — Julian backlog). **Compiler status** = whether the underlying gap is closed in `compiler/`.

| ID | Gap script | Report | Compiler status | Regression |
|----|------------|--------|-----------------|------------|
| BUG-C-01 | `dot4_loop_ensures_lean_stub_gap.sh` | [BUG-C-01.md](BUG-C-01.md) | **Resolved** — [PR #696](https://github.com/li-langverse/lic/pull/696) | PASS |
| BUG-C-02 | `bounds_guard_codegen_gap.sh` | [BUG-C-02.md](BUG-C-02.md) | **Resolved** | PASS |
| BUG-C-03 | `broadcast_len1_codegen_lean_gap.sh` | [BUG-C-03.md](BUG-C-03.md) | Open (Lean spec) | PASS |
| BUG-C-04 | `horner_fma_numerically_stable_gap.sh` | [BUG-C-04.md](BUG-C-04.md) | **Resolved** | PASS |
| BUG-C-05 | `mat2_at2_mir_codegen_lean_gap.sh` | [BUG-C-05.md](BUG-C-05.md) | **Resolved** (eval; MIR lemma deferred) | PASS |
| BUG-C-06 | `matmul_loop_codegen_witness_gap.sh` | [BUG-C-06.md](BUG-C-06.md) | **Resolved** (partial 2×2 witness) | PASS |
| BUG-C-07 | `method_call_requires_lean_gap.sh` | [BUG-C-07.md](BUG-C-07.md) | Open (witness-only) | PASS |
| BUG-C-08 | `parallel_disjoint_lean_opaque_gap.sh` | [BUG-C-08.md](BUG-C-08.md) | **Resolved** | PASS |
| BUG-C-09 | `prelude_linalg_manifest_tier_gap.sh` | [BUG-C-09.md](BUG-C-09.md) | Open (manifest tier) | PASS |
| BUG-C-10 | `sum_dot_product_equiv_gap.sh` | [BUG-C-10.md](BUG-C-10.md) | Open (no Lean equiv) | PASS |
| BUG-C-11 | `vec3_dot_opaque_ensures_gap.sh` | [BUG-C-11.md](BUG-C-11.md) | Open (opaque ensures) | PASS |
| BUG-C-12 | `vec3_len_callproc_ensures_gap.sh` | [BUG-C-12.md](BUG-C-12.md) | **Resolved** | PASS |
| BUG-C-13 | *(RFC — axiom decl / VC skip)* | [BUG-C-13-li-axiom-declarations.md](BUG-C-13-li-axiom-declarations.md) | RFC (phase 10) | — |

## Owner

Compiler / VC / Lean wiring: **Julian** (human). Proof Explorer agents: audit docs, discrepancies, catalog honesty only.
