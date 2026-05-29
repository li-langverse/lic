# Proof-gap digest — session `c8f2a91d-4e6b-4a1c-9f3d-202605291005` (cycle 2)

**Agent:** `proof_gap_researcher` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem · **PH-2e, PH-2f**  
**Focus step:** `mat2_codegen_eval_drift` (one focus — codegen ↔ Lean semantic alignment)  
**Repo:** `lic` · **Whitepaper:** `research-findings/whitepapers/2026-05/provability_holes/prov-r0-cycle2-mat2-codegen-drift/`

---

## Executive summary

- **Focus:** `disc-mat2-trusted-vs-mir` — whether MIR/LLVM `@` matches `Li.Discharge.mat2_at2_eval` used in AutoVC discharge.
- **Static alignment:** `emit_matmul2d_ijk_*` implements \(C_{ij} = \sum_t A_{it} B_{tj}\) (`compiler/codegen/emit.cpp:219-294`), matching `mat2_at2_eval` / `mat2_at2_float_spec` (`Discharge.lean:40-53`).
- **Runtime golden added:** `li-tests/math_linalg/golden_mat2_at2_float.li` — fixed 2×2 tiles; `verify-math-physics-goldens.sh` expects sink `19` (C[0][0]).
- **Proof certificate gap remains:** AutoVC `ensures` is discharged against `mat2_at2_eval`, not MIR (`build/generated/AutoVC.lean:14-15`); no preservation lemma (**G-meta** / **G-lean** row still Partial).
- **`mat2_at2_eval` is not in `trusted.lean`** — lives in `Discharge.lean` as definitional semantics; drift is **spec vs codegen**, not axiom abuse.
- **VC witness name is historical** — `witness_mat2_int_at2_spec` matches float 4-conjunct ensures (`vc_witness.cpp:474-484`).
- **No `trusted.lean` edits** this session.

---

## 1. Compiler / semantics gaps

| Gap | Evidence | Repro |
|-----|----------|-------|
| Lean proves eval semantics, not MIR | `vc_emit_lean.cpp:427-438` emits `mat2_at2_float_spec A B (mat2_at2_eval A B)` | `lic build li-tests/contracts_verify/linalg_mat2_at2_float_closed.li` → grep `build/generated/AutoVC.lean` |
| MIR `@` → `ArrayMatMul2DF64` | `lower.cpp:1176-1182` — `m×k` × `k×n` | 2×2 `@` lowers with `int_value=2, rhs_int=2, lhs_int=2` |
| LLVM IKJ matches eval formula | `emit.cpp:243-254` — `aik * b[t,j]` accumulate | Same as `Discharge.lean` entry sums |
| **G-meta** preservation | `MIR.lean` absent | deferred |
| Runtime ↔ eval (2×2) | `golden_mat2_at2_float.li` + goldens script | `./scripts/verify-math-physics-goldens.sh` |

---

## 2. Contract gaps

| Item | Status | Evidence |
|------|--------|----------|
| `prove_lean_ok` mat2 closed | **Done** (specimen) | `manifest.toml` → `linalg_mat2_at2_float_closed.li` |
| Ensures tied to eval, not return expr | By design for discharge theorem | `AutoVC.lean:14-15` |
| Golden uses `compile_ok` + runtime script | Smoke, not `prove_lean_ok` | `manifest.toml` `golden_mat2_at2_float.li` |

---

## 3. Trusted surface

| Item | Location | Notes |
|------|----------|-------|
| `mat2_at2_eval` | `Discharge.lean:47-53` | Definitional — **not** `trusted.lean` |
| `mat2_at2_float_spec_proved` | `Discharge.lean:56-59` | `rfl` witness — no `sorry` |
| `disc-mat2-trusted-vs-mir` | `proof-database/discrepancies.json:79-89` | Kind `spec_drift`, resolution `pending` |

---

## 4. External trust boundaries

| Boundary | Assumption |
|----------|------------|
| LLVM FMA vs serial multiply-add | `-ffast-math` in golden script may differ from pure serial semantics; 2×2 unrolled path uses FMA when enabled (`emit.cpp:274-275`) |
| Float equality in golden | Exact `!=` on literals — OK for representable tiles |

---

## 5. Evidence pack

### Hypothesis outcomes (cycle 2)

- `HYPOTHESIS: verified — LLVM IKJ matmul uses C[i][j] += A[i][t]*B[t][j] matching mat2_at2_eval entry formulas | evidence: emit.cpp:243-254, Discharge.lean:50-53`
- `HYPOTHESIS: verified — 2×2 float @ runtime matches mat2_at2_eval on fixed tiles | evidence: golden_mat2_at2_float.li; verify-math-physics-goldens.sh exit 0`
- `HYPOTHESIS: verified — AutoVC discharge proves spec w.r.t. mat2_at2_eval, not MIR lowering | evidence: build/generated/AutoVC.lean:14-15; vc_emit_lean.cpp:427-438`
- `HYPOTHESIS: falsified — mat2_at2_eval is listed in trusted.lean | evidence: trusted.lean has IO/Net/sqrt only; eval in Discharge.lean:47`
- `HYPOTHESIS: deferred — Formal MIR ↔ eval preservation (close disc-mat2-trusted-vs-mir) | evidence: MIR.lean missing; G-meta Missing`

### Commands run (2026-05-29)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic
LIC=./build/compiler/lic/lic
$LIC check li-tests/math_linalg/golden_mat2_at2_float.li                    # exit 0
./scripts/verify-math-physics-goldens.sh                                     # exit 0 (includes mat2 golden)
$LIC build li-tests/contracts_verify/linalg_mat2_at2_float_closed.li -o /tmp/x # exit 0, lake ok
./li-tests/run_all.sh math_linalg                                              # pass=27 fail=0
```

### New test

- `li-tests/math_linalg/golden_mat2_at2_float.li` — G-math runtime witness for **P-linalg** / `disc-mat2-trusted-vs-mir`.

---

## Recommended issues/PRs

| Repo | Title | Labels |
|------|-------|--------|
| `lic` | `feat(semantics): MIR.lean + mat2 @ preservation lemma (disc-mat2-trusted-vs-mir)` | `pillar:provable`, `PH-2e` |
| `lic` | `docs(verification): clarify G-lean row — eval proved, codegen preservation open` | `documentation`, `PH-2f` |
| `lic` | `chore(proof-db): resolve disc-mat2-trusted-vs-mir after preservation sketch` | `pillar:provable` |

---

## Deferred

- Full **G-meta** compiler ↔ Lean equivalence.
- General `N×N` matmul preservation (not only 2×2 witness).
- Connect `prove_lean_ok` golden to Lean (runtime test stays `compile_ok`).

---

## Error

None this session.
