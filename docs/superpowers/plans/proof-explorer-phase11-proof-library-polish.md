# Proof Explorer Phase 11 — proof-library polish

**Branch (proof-library):** `cursor/proof-library-site-polish`  
**Branch (lic sprint):** `cursor/proof-library-site-polish`  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase11-proof-library-polish.md`  
**Completion gate:** `scripts/proof-explorer-phase11-completion-gate.sh`

## Goals

| # | Goal | Implementation |
|---|------|----------------|
| 1 | Stale `library.json` | `build-library.py` with `LIC_ROOT`; commit `data/library.json`; Pages |
| 2 | Lean unknown ~94% | Glob `proof-db/**/*.lean`; catalog fallback for open/target/proved |
| 3 | Stub Li visible | Strip `main`, `_axiom_witness`; prefer `li_axiom_symbol`; skip `witness_stub` |
| 4 | Stdlib no drilldown | `index.json` → `lean_module` + ProofDB lean snippets |
| 5 | Erdős thin drilldown | `formal_statement` role + statement section in UI |
| 6 | Problem register UX | "open target" badge; epistemic copy on erdos rows |

## Verification

```bash
LIC_ROOT=../lic python3 ../proof-library/scripts/build-library.py
bash ../proof-library/scripts/check-library-quality.sh
bash ../proof-library/scripts/check-no-proc-in-library.py
```

Expect **lean_status unknown** well below 50% of entries and all five stdlib ids with `lean_formal` drilldown.
