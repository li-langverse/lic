# Proof Explorer Phase 12 — catalog quality across whole corpus

**Branch (lic):** `cursor/proof-explorer-phase12-catalog-quality`  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase12-catalog-quality.md`  
**Completion gate:** `scripts/proof-explorer-phase12-completion-gate.sh`

## Goals

| # | Goal | Implementation |
|---|------|----------------|
| 1 | 27 catalog↔Lean divergent rows | Honest `proof_status` (`axiomatic`, `proved`, `discrepancy`) on domain + stdlib rows |
| 2 | Physics placeholders | `P-AX-DIM-*`, `P-LM-MOM-001` → `discrepancy`; document Lean stub names |
| 3 | Float triangle sorry | `std_triangle_ineq_scalar` + `std_dot4_bilinear_right` index honesty |
| 4 | Domain axiom specimens | `stub-audit.py` clean on M-AX-* + vertical axiom paths |
| 5 | Non-Erdős enrichment | math/linalg/discrete lemma `li_specimen` + contract comments |
| 6 | proof-library | Rebuild `library.json`; 0 unknown spike; 0 witness leaks; divergent ≤ 5 |
| 7 | Loop state | `state.json` phase 12 + iteration-log + signoffs |
| 8 | Site deploy | proof-library PR merge + Pages |

## Verification

```bash
python3 scripts/proof-db/compare_reference.py --write
LIC_ROOT=. python3 ../proof-library/scripts/build-library.py
bash ../proof-library/scripts/check-library-quality.sh
python3 ../proof-library/scripts/check-no-proc-in-library.py
bash scripts/proof-explorer-phase12-completion-gate.sh
```

## Non-goals

- No `compiler/` edits (report-only for BUG-C gaps).
- No claiming Erdős **proved** when register is **open** / **target**.
