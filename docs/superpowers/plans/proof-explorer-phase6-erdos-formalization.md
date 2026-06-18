# Proof Explorer Phase 6 — Erdős P0 + M-CONJ partial formalization

## Motivation

Phase 5 establishes trustworthy discharge for **core compiler lemmas**. Phase 6 applies that toolchain to **high-value open math**: Erdős P0 problems (including **E-52** and **Bloom Top-10** partial proofs) and **M-CONJ** Millennium/Landau targets — upgrading specimens from open stubs to partial or discharged formalizations with evidence-backed catalog status.

Research claims from Phase 3 (E-52 claim ledger) inform formalization targets but **do not** auto-upgrade proof status.

---

## North star

At least **five P0 Erdős** rows move from `li_open` → `li_proved` or carry an **honest partial discharge** (sub-lemma with verify evidence). At least **three M-CONJ** rows have **non-trivial** `.li` specimens (quantified statements, not placeholder comments). E-52 and Bloom Top-10 have structured partial-proof tranches linked to research claims.

---

## Prerequisite

Phase 5 gate must pass:

```bash
bash scripts/proof-explorer-phase5-completion-gate.sh
```

---

## Priority targets

### Erdős P0 (T2 tranche)

| Problem | Notes | Research link |
|---------|-------|---------------|
| **E-52** | Sumset / cardinality gap — Phase 3 claim ledger exists | `proof-db/research-claims/E-52/` |
| **Bloom Top-10** | Subset of P0 with Bloom-filter relevance tags in register | `proof-db/erdos/register.json` `tags` |
| Other P0 | Remaining `priority_tier = P0` open rows | specimen stubs from Phase 4 |

### M-CONJ (T1 tranche)

Millennium + Landau targets with existing stubs:

- `M-CONJ-RH`, `M-CONJ-P-NP`, `M-CONJ-NAVIER`, `M-CONJ-HODGE`, `M-CONJ-YM`, …
- Non-trivial = formalized conjecture statement in Li (types, quantifiers, no `# TODO` body only)

---

## Work packages

| WP | Name | Deliverable | Completion criteria | Gate |
|----|------|-------------|---------------------|------|
| **WP-EF-01** | E-52 formalization | Strengthen `proof-db/erdos/specimens/E-52.li` + claim-linked sub-specimens | ≥1 sub-specimen with partial discharge or `li_open` formal statement matching CLM rows | `wp-erdos-p0-discharge.sh` (E-52 slice) |
| **WP-EF-02** | Bloom Top-10 tranche | Pick 10 P0 Bloom-tagged problems; strengthen stubs | ≥3 with non-trivial formal statements; ≥1 partial discharge | `wp-erdos-p0-discharge.sh` |
| **WP-EF-03** | P0 discharge sprint | ≥5 P0 Erdős: `li_proved` or honest partial | `discharge-log.jsonl` entries; epistemic_status sync in claims | `wp-erdos-p0-discharge.sh` |
| **WP-EF-04** | M-CONJ formalization | ≥3 M-CONJ non-trivial specimens | Quantified `.li` bodies; catalog `formalization_status` updated | `wp-mconj-formalization.sh` |
| **WP-EF-05** | export-math li_specimen | `lic export-math` emits `li_specimen` for formalized rows | Export JSON includes path for ≥5 upgraded rows | `wp-export-li-specimen.sh` |
| **WP-EF-06** | claim ↔ catalog sync | Map discharged lemmas to claim ledger `epistemic_status` | E-52 compare report shows ≥1 `li_proved` or honest `li_open` refinement | manual |
| **WP-EF-SIGN** | sign-off | Human review of P0/M-CONJ upgrades | `data/proof-explorer-loop/wp-erdos-formalization.signoff` | phase gate |

---

## Partial discharge honesty

Allowed catalog states for hard problems:

| State | Meaning | `proof_status` |
|-------|---------|----------------|
| **Full discharge** | `lic verify` exit 0 on main specimen | `proved` (with evidence) |
| **Partial lemma** | Sub-theorem discharged; main conjecture open | `target`; sub-row in `partial_proofs[]` |
| **Formal open** | Statement formalized, no discharge | `open` or `target`; `formalization_status = li_open` |
| **Literature anchor** | Cited result, not re-proved | `target`; `formalization_status = literature_proved` |

Never: `proof_status = proved` on E-52 main conjecture from model consensus alone.

---

## Do not

- Upgrade all 1217 Erdős rows — Phase 6 targets P0 + Bloom Top-10 only.
- Copy model prose from claim ledger into `.li` files without type-checking.
- Set `erdos_status = proved` in catalog from partial sub-lemmas.
- Regress Phase 5 core discharges or Phase 4 coverage invariant.
- Skip M-CONJ because Erdős is more visible — gate requires both tracks.

---

## Completion gate

```bash
bash scripts/proof-explorer-phase6-completion-gate.sh
```

| Check | Threshold |
|-------|-----------|
| P0 Erdős discharges | ≥ 5 with `li_proved` **or** documented partial discharge |
| M-CONJ specimens | ≥ 3 non-trivial (script-checked) |
| E-52 | Claim ledger + specimen cross-linked |
| export-math | `li_specimen` field present on upgraded rows |
| Sign-off | `wp-erdos-formalization.signoff` |

When exit 0 → `GOAL_COMPLETE` → handoff to Phase 7.
