# Li coverage invariant (Proof Explorer Phase 4)

Every catalog row must be **formally grounded** in Li or explicitly marked as an open formalization gap. No row may sit in metadata-only limbo.

## Invariant (per catalog entry)

| Condition | Required fields | `proof_status` rule |
|-----------|-----------------|---------------------|
| **Li discharged** | `li_specimen` → existing `.li` file; `lean_thm` or verify log | May be `proved` only with verify evidence |
| **Li open target** | `li_specimen` → existing `.li` stub; `gap_id` + `gap_kind` | Must be `open` or `target` |
| **Axiomatic** | `lean_module` → Lean axiom module (math axioms only) | `axiomatic` |
| **Literature proved, not yet formalized** | `li_specimen` open stub; `erdos_status = proved`; `gap_id` | Catalog `proof_status` must **not** be `proved` until Li discharge — use `target` + `formalization_status = literature_proved` |

Forbidden:

- `proof_status = proved` without Li verify or explicit `lean_thm` discharge
- Missing both `li_specimen` and `gap_id`
- `li_specimen` path that does not exist on disk

## Tranches (completion order)

1. **T0** — Math lemmas + axioms (`M-AX-*`, `M-LM-*`)
2. **T1** — Open conjectures (`M-CONJ-*`)
3. **T2** — Erdős P0 (`priority_tier = P0`)
4. **T3** — Erdős literature-proved (`erdos_status = proved`) — downgrade catalog `proved` → `target` until formalized
5. **T4** — Remaining Erdős open + other fields

## Tooling

- `scripts/formalization/check-li-coverage.py` — audit + JSON report
- `scripts/formalization/bootstrap-specimen-stubs.py` — generate open `.li` stubs + patch catalog
- `scripts/proof-explorer-gates/wp-li-coverage.sh` — gate wrapper
- `scripts/proof-explorer-phase4-completion-gate.sh` — phase completion

## Phase 4 gate (minimum)

| Tranche | Coverage required |
|---------|-------------------|
| T0 math lemmas/axioms | 100% |
| T1 M-CONJ | 100% |
| T2 Erdős P0 | 100% |
| T3+ | ≥ 5% overall Erdős with `li_specimen` (agent iterates upward) |

Human sign-off: `data/proof-explorer-loop/wp-li-coverage.signoff`
