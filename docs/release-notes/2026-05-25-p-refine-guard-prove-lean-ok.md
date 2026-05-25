# P-refine: guard-branch discharge + prove_lean_ok corpus extension

## Summary

`if n >= 0` guarded refinement call-sites emit `Li.Discharge.refinement_nonneg_spec` with a guard hypothesis and `refinement_nonneg_lit_proved`; `refinement_{inline,local,guard}_ok` join `prove_lean_ok` in `li-tests/manifest.toml`.

## Agent continuation

1. **Read:** `compiler/verify/vc_emit_lean.cpp`, `li-tests/tooling/discharge_refinement_lean.sh`.
2. **Run:** `./li-tests/tooling/contracts_discharge_corpus.sh`; `./li-tests/run_all.sh contracts_verify`.
3. **Then:** branch-scoped `assum_nonneg_ints`; `refinement_init_ok` init VC discharge.
4. **Blocked on:** universal float `abs` (**P-float**); Lean **P-dec** proofs.

## Changed

| Path | Evidence |
|------|----------|
| `compiler/verify/vc_emit_lean.cpp` | Guard-branch `refinement_nonneg_spec` + `hguard_*` |
| `li-tests/manifest.toml` | `refinement_{inline,local,guard}_ok` → `prove_lean_ok` |
| `li-tests/tooling/discharge_refinement_lean.sh` | Four P-refine specimens |
| `docs/verification/provability-gaps.md` | **G-test-verify** / **P-refine** |
| `docs/verification/proof-corpus-roadmap.md` | Corpus rows |

## Not changed

- `sqrt_open_bound` lemmas (on `main`).
- `refinement_init_ok` (`verify_ok`).
- HTTPd, Studio, tier-1 benches.

## Breaking / Security / Performance / Downstream

N/A
