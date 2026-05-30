# P-linalg loop ≡ closed-form ensures (PH-2i / PH-2f / G-lean)

> **Issue:** [#472](https://github.com/li-langverse/lic/issues/472) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-lean / G-vc), **Fast** (tier-1 matmul/horner advisory only after witness policy)  
> **Learned from:** [2026-05-16-li-math-linalg-surface.md](./2026-05-16-li-math-linalg-surface.md), [proof-corpus-roadmap.md](../../verification/proof-corpus-roadmap.md), [Discharge.lean](../../semantics/Discharge.lean) (`dot4_int_loop_eval_spec`), [proof_gap_researcher cycle 21](https://github.com/li-langverse/benchmarks/blob/main/data/digest/proof_gap_researcher-2026-05-30-horner-fma-lean-drift.md)

## Goal

Close or honestly split the open sub-plan gate **“P-linalg loop implementation ≡ closed-form `ensures` in Lean (**G-lean**)”** in the math-linalg surface plan. Use the closed **dot4 int loop** witness as the template; define scoped slices for float dot, matmul IKJ, and Horner FMA so `plan-completion-audit` and `provability-gaps.md` stop overclaiming partial closure.

## Non-goals

- Proving full N×N matmul loop ≡ closed `@` spec in one PR (defer to staged witnesses).
- Closing **G-hw** / **G-meta** (FMA vs sequential float; compiler↔Lean equivalence).
- Editing `trusted.lean` or adding axioms for hardware FMA.
- Weakening tier-1 benchmark thresholds to green incomplete proof slices.
- Horner tier-1 perf claims as Lean-closed (**G-math** advisory only until P-float slice lands).

## Dependencies

- **PH-2i**, **PH-2f** — P-linalg corpus (#151, #155).
- **PH-7e** — matmul/horner codegen paths (witness must match emitted MIR).
- **proof_gap_researcher** cycle 21 — Horner FMA drift harness (`horner_fma_codegen_lean_drift.sh`).
- Human: approve P-float pilot scope before float loop witnesses ship.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Reconcile gate** — update `2026-05-16-li-math-linalg-surface.md` exit checklist: dot4 int **Done**; remaining slices listed | Audit `plan_files_open` no longer flags ambiguous single checkbox |
| B | **Int reduction corpus** — extend dot4 pattern to fixed-trip `sum` / small matmul entry (2×2 int `@` loop if not already closed) | `discharge_linalg_int_lean.sh` green; new `*_loop_open.li` rows in manifest |
| C | **Float dot pilot** — `witness_dotN_float_loop` + `Discharge` eval spec for N=4 (no FMA) | `linalg_dot4_float_loop_open.li` → `verify_ok`; **G-vc** slice documented |
| D | **Matmul IKJ witness design** — static trip + acc pattern for tier-1 `matmul_naive` inner loop (int pilot first) | `matmul_loop_codegen_witness_gap.sh` documents open vs dot4 contrast |
| E | **Horner deferred slice** — link to P-float backlog; tier-1 bench stays codegen-advisory | `provability-gaps.md` G-math row cites cycle 21 digest |
| F | **Tracker sync** — master plan PH-2i / 2f partial bullets + close lic#472 when A–E merged | `plan-completion-audit` `master_plan_open` 2i gate honest |

## Tests / benches

- `li-tests/contracts_verify/linalg_dot4_int_loop_open.li` — reference closed slice (no regression).
- `li-tests/tooling/discharge_linalg_int_lean.sh` — expand for new int loop specimens.
- `li-tests/tooling/matmul_loop_codegen_witness_gap.sh` — gate matmul witness absence until sub D.
- `li-tests/tooling/horner_fma_codegen_lean_drift.sh` — Horner stays open; contrast dot4.
- Tier-1: `matmul_naive`, `horner_pure_li` — perf advisory only; no proof closure claim in bench docs.

## Provability

| G-* | Movement | Honest limit |
|-----|----------|--------------|
| **G-lean** | Partial → stronger Partial (more closed slices, explicit open list) | Full kernel gate still blocked on `sqrt_open_bound`, float matmul |
| **G-vc** | Partial — int loop slices closed; float opaque returns remain | `vec3_dot`, CallProc ensures still open |
| **G-math** | Partial — document horner/matmul tier-1 as codegen-advisory | No **Done** until witnesses + eval specs land |
| **G-hw**, **G-meta** | Unchanged | FMA / fast-math documented, not closable this plan |

## Rollout

1. Merge this plan PR → maintainer adds **`plan-approved`** on #472.
2. Sub A + provability-gaps.md honesty PR (docs-only).
3. Sub B–C implementation PR(s) — int then float pilot.
4. Sub D matmul witness design PR — may span compiler + Lean.
5. Sub E cross-link benchmarks digest; Sub F tracker checkbox PR.
6. Remove `plan-needed` on #472 when A–F exit gates met.

## Human-only

- Approve **`plan-approved`** before implementation agents run.
- Decide float loop witness policy (`--numerically-stable` parity with matmul IKJ vs Horner FMA).
- No `trusted.lean` edits without separate human-approved issue.
