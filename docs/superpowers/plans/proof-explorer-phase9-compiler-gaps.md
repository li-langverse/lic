# Proof Explorer Phase 9 — compiler gap closure (honest catalog)

**Branch:** `cursor/proof-explorer-compiler-gaps` (merge to `main` after review)  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase9-compiler-gaps.md`  
**Completion gate:** `scripts/proof-explorer-phase9-completion-gate.sh`

## Motivation

Proof Explorer phases 1–8 grew the **proof-db catalog** and research corpus. Compiler maturity (VC emission, MIR↔Lean, parallel contracts) still lags **catalog honesty**: rows must not claim `proof_status = proved` while tooling gap scripts fail.

**Human role (fixed):** Julian edits `compiler/` and Discharge lemmas. Agents file **audit reports**, maintain **gap scripts in CI**, reconcile **discrepancies.json**, and keep the catalog epistemically consistent — never patch the compiler from agent goals.

## North star

1. **BUG-C audit index** — every `li-tests/tooling/*_gap.sh` has a `docs/reports/compiler-audit/BUG-C-NN.md` row.
2. **Regression harness** — `wp-compiler-gap-regression.sh` runs all gap scripts; **BUG-C-01 (dot4)** must pass after PR #696; others may remain open but are tracked.
3. **Discrepancy register** — `python3 scripts/proof-db/compare_reference.py --write` keeps `proof-database/discrepancies.json` aligned with Lean/AutoVC truth.
4. **Catalog honesty** — no `proof_status = proved` on specimens whose gap script still fails.
5. **Prioritize or downgrade** — vec3_dot, mat2 MIR, parallel disjoint: either promote to Julian backlog or downgrade catalog claims + provability-gaps.md in the same agent PR (docs only).

## Work packages

| WP | Scope | Gate |
|----|-------|------|
| **WP-CG-01** | Merge dot4 AutoVC discharge (#696) | `dot4_loop_ensures_lean_stub_gap.sh` passes |
| **WP-CG-02** | BUG-C audit index + stub reports | `wp-compiler-gap-audit-index.sh` |
| **WP-CG-03** | Gap regression (all `*_gap.sh`) | `wp-compiler-gap-regression.sh` |
| **WP-CG-04** | Reconcile discrepancies | `wp-discrepancy-reconcile.sh` |
| **WP-CG-05** | Catalog honesty | `wp-catalog-honesty.sh` |
| **WP-CG-06** | (Optional) destub CallProc specimens | `wp-destub-proc-specimens.sh` |

## Gap script register (BUG-C)

| ID | Gap script | Status (2026-06-01) |
|----|------------|------------------------|
| BUG-C-01 | `li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh` | **Resolved** — PR #696 |
| BUG-C-02 | `bounds_guard_codegen_gap.sh` | Open |
| BUG-C-03 | `broadcast_len1_codegen_lean_gap.sh` | Open |
| BUG-C-04 | `horner_fma_numerically_stable_gap.sh` | Open |
| BUG-C-05 | `mat2_at2_mir_codegen_lean_gap.sh` | Open |
| BUG-C-06 | `matmul_loop_codegen_witness_gap.sh` | Open |
| BUG-C-07 | `method_call_requires_lean_gap.sh` | Open |
| BUG-C-08 | `parallel_disjoint_lean_opaque_gap.sh` | Open |
| BUG-C-09 | `prelude_linalg_manifest_tier_gap.sh` | Open |
| BUG-C-10 | `sum_dot_product_equiv_gap.sh` | Open |
| BUG-C-11 | `vec3_dot_opaque_ensures_gap.sh` | Open |
| BUG-C-12 | `vec3_len_callproc_ensures_gap.sh` | Open |

## Agent iteration rules

1. Read `data/proof-explorer-loop/state.json` (`phase` 9, `current_wp` = `wp-cg-*`).
2. Branch `cursor/proof-explorer-compiler-gaps`; one WP per iteration when possible.
3. **Do not** edit `compiler/`, `docs/semantics/Discharge.lean`, or `vc_*.cpp` — file `docs/reports/compiler-audit/BUG-C-*.md` instead.
4. After catalog changes: `python3 scripts/proof-db/proof-db.py verify-slice`.
5. Run WP gate, then `bash scripts/proof-explorer-phase9-completion-gate.sh` before claiming phase complete.

## K8s handoff

- `LI_PROOF_EXPLORER_PHASE_HANDOFF=1`
- `LI_PROOF_EXPLORER_BRANCH=main` (after phase9 docs merge) or feature branch until merged
- Unset `LI_PROOF_EXPLORER_GOAL_FILE` (handoff picks first incomplete phase)
- Optional: `LI_PROOF_EXPLORER_PHASES_JSON` with only `phase9` to skip earlier phases once gates pass

## References

- `docs/verification/provability-gaps.md`
- `proof-database/DISCREPANCIES.md`
- `docs/release-notes/2026-05-25-proof-db-discrepancies.md`
