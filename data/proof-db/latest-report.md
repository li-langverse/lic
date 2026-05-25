# Proof database — lemma rebuild report

> **Policy:** failure/open = gap to investigate — not Li wrongness.

- **Generated:** 2026-05-25T12:46:05Z
- **lic commit:** `e3be2db830d17033d6d67965643a5ad1afd5fd79`

## Summary

| proved | open | failed | skipped | axiomatic | mismatch |
|--------|------|--------|---------|-----------|----------|
| 18 | 0 | 5 | 4 | 10 | 0 |

## Per entry

| id | catalog | rebuild | open_goals | notes |
|----|---------|---------|------------|-------|
| P-linalg-dot4-int-closed | proved | proved | 0 |  |
| P-linalg-dot4-int-loop-open | proved | proved | 0 |  |
| P-float-sqrt-open-bound | proved | proved | 0 |  |
| G-lean-autovc-strict | open | proved | 0 |  |
| P-discharge-trivial | proved | proved | 0 |  |
| A-trusted-getelem | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-PEANO-ZERO-NOT-SUCC | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-PEANO-SUCC-INJ | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-PEANO-IND | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-ORDER-TRICHOTOMY | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-ORDER-ANTISYM | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-REAL-ADD-COMM | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-REAL-ADD-ASSOC | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-REAL-MUL-DIST | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-AX-REAL-MUL-ONE | axiomatic | axiomatic | — | Axiomatic — not user-code wrongness. |
| M-LM-ADD-COMM | proved | proved | 0 |  |
| M-LM-ADD-ASSOC | proved | proved | 0 |  |
| M-LM-MUL-ONE | proved | proved | 0 |  |
| M-LM-NAT-ADD-ZERO | proved | proved | 0 |  |
| M-LM-NAT-ADD-COMM | proved | proved | 0 |  |
| M-LM-FLOAT-ADD-COMM | discrepancy | build_failed | — | Build failed — investigate VC/specimen. |
| M-LM-ORDER-TRANS | open | proved | 0 |  |
| M-LM-MUL-DIST-INST | open | build_failed | — | Build failed — investigate VC/specimen. |
| P-AX-CONS-001 | open | build_failed | — | Build failed — investigate VC/specimen. |
| P-AX-CONS-002 | open | build_failed | — | Build failed — investigate VC/specimen. |
| P-AX-DIM-001 | open | skipped | — | No li_specimen. |
| P-AX-DIM-002 | open | skipped | — | No li_specimen. |
| P-LM-ENERGY-001 | proved | skipped | — | No li_specimen. |
| P-LM-MOM-001 | proved | skipped | — | No li_specimen. |
| P-LM-CONS-001 | open | build_failed | — | Build failed — investigate VC/specimen. |
| P-AX-MECH-001 | open | proved | 0 |  |
| P-AX-MECH-002 | open | proved | 0 |  |
| P-AX-MECH-003 | open | proved | 0 |  |
| G-lean-autovc-strict | open | proved | 0 |  |
| P-float-sqrt-open-bound | proved | proved | 0 |  |
| P-linalg-dot4-int-closed | proved | proved | 0 |  |
| P-linalg-dot4-int-loop-open | proved | proved | 0 |  |

Failures = proof gaps, not user-code wrongness.
