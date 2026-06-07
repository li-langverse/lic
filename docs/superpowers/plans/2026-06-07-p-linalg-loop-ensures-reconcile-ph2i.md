# P-linalg loop ≡ ensures — reconcile gate & split backlog (PH-2i / PH-2f / G-lean)

> **Issue:** [#472](https://github.com/li-langverse/lic/issues/472) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-lean / G-vc / G-math), **Fast** (tier-1 matmul/horner advisory only after witness policy)  
> **Learned from:** [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), [provability-gaps.md](../../verification/provability-gaps.md), [Discharge.lean](../../semantics/Discharge.lean) (`dot4_int_loop_eval_spec`, `matmul2_at2_loop_eval_spec`), [BUG-C-01](../../reports/compiler-audit/BUG-C-01.md) / [BUG-C-06](../../reports/compiler-audit/BUG-C-06.md)

## Goal

Resolve the **master-plan-gap** on lic#472: the math-linalg sub-plan exit gate **“P-linalg loop implementation ≡ closed-form `ensures` in Lean (**G-lean**)”** is **partially satisfied on `main`** (fixed-trip int dot + 2×2 matmul witnesses) but **audit and tracker text still drift** (`plan-completion-audit` May 30 snapshot, master plan row “loop dot open”). This plan **reconciles** the gate with shipped evidence, **splits** remaining loop↔ensures obligations into tracked **P-linalg** slices linked from PH-2i / Phase 2f, and defines honest **Done** criteria so implementation agents do not overclaim or re-open closed specimens.

## Current state (2026-06-07)

| Slice | Evidence | Status |
|-------|----------|--------|
| Fixed 4-term int dot loop | `linalg_dot4_int_loop_open.li`, `dot4_int_loop_eval_spec`, `dot4_loop_ensures_lean_stub_gap.sh` PASS | **Closed** ([PR #696](https://github.com/li-langverse/lic/pull/696), BUG-C-01) |
| Closed-form int dot/sum/matmul-entry | `discharge_linalg_int_lean.sh`, `linalg_*_closed.li` corpus | **Closed** (#151) |
| 2×2 float `@` closed-form | `linalg_mat2_at2_float_closed.li`, `mat2_at2_float_spec` | **Closed** |
| 2×2 matmul IKJ loop witness | `witness_matmul2_at2_spec`, `matmul2_at2_loop_eval_spec`, `matmul_loop_codegen_witness_gap.sh` PASS | **Closed (partial)** (BUG-C-06) |
| math-linalg sub-plan checkbox | `2026-05-16-li-math-linalg-surface.md` line 175 | **Checked** on `main` |
| Master plan PH table row 373 | “loop dot open” | **Stale** — contradicts line 455 + provability-gaps |
| Float dot loop, vec3 opaque, full N×N matmul, Horner FMA loop | `provability-gaps.md` P-linalg partial | **Open** |

## Non-goals

- Proving full N×N matmul loop ≡ closed `@` spec in one PR (staged witnesses only).
- Closing **G-hw** / **G-meta** (FMA vs sequential float; compiler↔Lean equivalence).
- Editing `trusted.lean` or adding axioms for hardware FMA.
- Weakening tier-1 benchmark thresholds to green incomplete proof slices.
- Reverting or re-stubbing closed dot4 / matmul2 witnesses.
- Claiming universal `lic build` = Lean certificate (kernel still **Partial** per G-lean).

## Dependencies

- **PH-2i**, **PH-2f** — P-linalg corpus (#151, #155, #696).
- **PH-7e** — matmul/horner codegen paths (witness must match emitted MIR).
- **proof_gap_researcher** — Horner FMA drift harnesses (`horner_fma_*_gap.sh`).
- **benchmarks** `plan-completion-audit.py` — re-run after tracker sync (Sub A).
- Human: approve P-float pilot scope before float loop witnesses ship.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Gate reconcile (docs-only)** — amend master plan row 373 (“loop dot **closed (fixed-trip)**; float / N×N open”); cross-link this plan from math-linalg surface exit gate footnote | `check-doc-provability-claims.sh` pass; audit no longer flags ambiguous single checkbox |
| **B** | **Backlog register** — add `P-linalg-loop-backlog` table to `proof-corpus-roadmap.md` listing open slices: float dot loop (N=4), vec3_dot opaque, sum/reduction parametric loop, N×N matmul loop, Horner FMA | Each row has specimen path or “design TBD”, gap id, owning issue slot |
| **C** | **Int reduction extension** — extend dot4 pattern to any remaining fixed-trip int `sum` / small matmul entry loops not yet in `discharge_linalg_int_lean.sh` | Script green; manifest `prove_lean_ok` or `verify_ok` rows updated |
| **D** | **Float dot pilot** — `witness_dotN_float_loop` + `Discharge` eval spec for N=4 (no FMA; `--numerically-stable` parity) | `linalg_dot4_float_loop_open.li` → `verify_ok`; **G-vc** slice documented |
| **E** | **Matmul N×N witness design** — static-trip + acc pattern for tier-1 `matmul_naive` beyond 2×2 (int pilot first, then float advisory) | New gap script or BUG-C row; contrast with closed matmul2 witness |
| **F** | **Horner deferred slice** — link to P-float backlog; tier-1 bench stays codegen-advisory | `provability-gaps.md` G-math row cites proof_gap digest; no “Done” claim |
| **G** | **Close lic#472** — when A–B merged + human **`plan-approved`**; remaining C–F tracked as separate implementer issues | Issue comment cites reconcile evidence; `plan-needed` removed |

## Tests / benches

| Artifact | Role |
|----------|------|
| `li-tests/contracts_verify/linalg_dot4_int_loop_open.li` | Reference closed slice — **no regression** |
| `li-tests/tooling/discharge_linalg_int_lean.sh` | Expand for new int loop specimens (Sub C) |
| `li-tests/tooling/dot4_loop_ensures_lean_stub_gap.sh` | Guard against `Prop := True` stubs (BUG-C-01) |
| `li-tests/tooling/matmul_loop_codegen_witness_gap.sh` | Guard matmul2 witness + FMA gate (BUG-C-06) |
| `li-tests/tooling/horner_fma_numerically_stable_gap.sh` | Horner stays open; contrast dot4 (Sub F) |
| Tier-1: `matmul_naive`, `horner_pure_li` | Perf advisory only; no proof closure claim in bench docs |

## Provability

| G-* | Movement | Honest limit |
|-----|----------|--------------|
| **G-lean** | Partial → **honest Partial** (closed fixed-trip slices enumerated; open list explicit) | Full kernel gate blocked on `sqrt_open_bound`, parametric loops |
| **G-vc** | Partial — int loop slices closed; float opaque returns remain | `vec3_dot`, CallProc ensures still open |
| **G-math** | Partial — document horner/matmul tier-1 as codegen-advisory | No **Done** until witnesses + eval specs land |
| **G-hw**, **G-meta** | Unchanged | FMA / fast-math documented, not closable this plan |

## Rollout

1. Merge **this plan PR** → maintainer adds **`plan-approved`** on #472.
2. **Sub A + B** — docs-only PR (master plan row 373, proof-corpus backlog table, provability-gaps cross-link).
3. **Sub C–D** — implementation PR(s): int extension then float dot pilot.
4. **Sub E** — matmul N×N witness design PR (may span compiler + Lean).
5. **Sub F** — cross-link benchmarks proof_gap digest.
6. **Sub G** — close #472 when A–B land; spin C–F to child issues if not already filed.

## Human-only

- [x] Add label **`plan-approved`** on #472 before implementation agents run.
- [ ] Decide float loop witness policy (`--numerically-stable` parity with matmul IKJ vs Horner FMA).
- [ ] Re-run `benchmarks/scripts/plan-completion-audit.py` with `LIC_ROOT` after Sub A merge.
- [ ] No `trusted.lean` edits without separate human-approved issue.

## Supersedes

- Closed draft [PR #530](https://github.com/li-langverse/lic/pull/530) (2026-05-30 plan) — incorporates shipped #696 / BUG-C-06 evidence and reconciles checked sub-plan gate on `main`.
