# Proof Explorer Phase 7 — Research audit at scale + proof-library integration

## Motivation

Phase 3 proved the **claim ledger + Li verification** pattern on a single problem (E-52). Phase 6 formalized priority Erdős/M-CONJ targets. Phase 7 **scales autonomous research audit** across multiple open problems and wires **proof-library** to consume full `export-math` output including `li_specimen` paths — making formal proof status visible to learners alongside model consensus and literature anchors.

---

## North star

At least **three distinct research problems** each have: structured claim ledger, multi-model reviews, Li verification batch, and compare report. **proof-library** consumes `lic export-math` JSON with `li_specimen` on all exported fields and renders specimen links + epistemic badges in the explorer UI.

---

## Prerequisite

Phase 6 gate must pass:

```bash
bash scripts/proof-explorer-phase6-completion-gate.sh
```

---

## Problem portfolio (minimum three)

| Problem ID | Type | Phase 3/6 seed |
|------------|------|----------------|
| **E-52** | Erdős P0 | Existing claim ledger — extend iterations |
| **ADHOC-HOROCONVEX-GAP** or next P0 | Ad-hoc / Erdős | New ledger from register pick |
| **M-CONJ-RH** or **M-CONJ-LANDAU-*** | M-CONJ | Formalized specimen from Phase 6 |

Agents pick additional problems from `proof-db/erdos/register.json` (`priority_tier` P0/P1) or M-CONJ open rows.

---

## Work packages

| WP | Name | Deliverable | Completion criteria | Gate |
|----|------|-------------|---------------------|------|
| **WP-RS-01** | Multi-problem ledgers | ≥3 problems with `claims.jsonl` + `reviews.jsonl` | Each ≥10 claims, ≥2 reviewer models | `wp-research-scale.sh` |
| **WP-RS-02** | Li verify at scale | Batch `claim-to-li-specimen.py` + `lic verify` per problem | Compare reports in `data/research-audit/{id}/` | `wp-li-verify-claims.sh` |
| **WP-RS-03** | Compare matrix | `compare-claims.py` for each problem | `unprovable_language_flags` documented | `wp-claim-compare.sh` |
| **WP-RS-04** | export-math full field | All math-field entries export with rich v3 fields + `li_specimen` | `wp-export-li-specimen.sh` + `wp3-export-math.sh` | both gates |
| **WP-RS-05** | proof-library integration | UI reads export; specimen links; claim audit pages | `data/proof-explorer-loop/wp-proof-library-export.signoff` with PR URL | `wp-proof-library-export.sh` |
| **WP-RS-06** | long-horizon loop | K8s profile for 70h-style research iterations | `LI_PROOF_EXPLORER_LOOP_SLEEP_SEC` + problem rotation in state | `wp-ra-problem.sh` |
| **WP-RS-SIGN** | program sign-off | End-to-end demo path documented | `data/proof-explorer-loop/wp-research-scale.signoff` | phase gate |

---

## proof-library integration requirements

Export consumer must surface:

1. **`li_specimen`** — link to `.li` file or raw view when present
2. **`proof_status`** vs **`formalization_status`** — distinct badges
3. **Claim explorer** — per-problem claim matrix (Phase 3 WP-AU extended)
4. **Epistemic status** — `li_proved`, `li_open`, `literature_proved`, `heuristic`, `model_conflict`

Fallback: if specimen missing (regression), show Phase 4 gap badge — gate must fail.

---

## Research iteration rules

1. Bind problem in `data/proof-explorer-loop/state.json` → `research_problem_id`.
2. Append claims (never chat-only).
3. Run reviewer lane before Li batch.
4. Run compare before any catalog upgrade.
5. Commit + push each iteration; append `iteration-log.md`.

---

## Do not

- Treat Phase 7 as "discharge all 1217" — scale is **problem count**, not corpus percentage.
- Hide `model_conflict` rows in proof-library UI.
- Ship proof-library without `li_specimen` in export (regresses Phase 6 WP-EF-05).
- Disable Phase 3 gates — Phase 7 **extends** WP-RA/CL/MR/LV/CM, not replaces.
- Auto-close the worker loop without all phase gates 2–7 passing.

---

## Completion gate

```bash
bash scripts/proof-explorer-phase7-completion-gate.sh
```

| Check | Threshold |
|-------|-----------|
| Research problems | ≥ 3 with ledger + compare report |
| Claims volume | ≥ 10 claims per problem (30+ total) |
| proof-library | Export integration sign-off + specimen links live |
| Phase 3 gates | wp-claim-ledger, wp-multi-review, wp-li-verify-claims still pass |
| Sign-off | `wp-research-scale.signoff` |

When exit 0 → **Proof Explorer program complete** (phases 1–7).
